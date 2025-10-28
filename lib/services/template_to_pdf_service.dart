import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

/// Service for converting Flutter template widgets to PDF format
/// This service captures the exact appearance of templates and converts them to PDF
/// maintaining the original layout, styling, and user inputs
class TemplateToPdfService {
  // PDF page constants
  static const PdfPageFormat _pageFormat = PdfPageFormat.a4;
  static const double _margin = 20.0;
  
  // Available page dimensions
  static double get availableWidth => _pageFormat.width - (_margin * 2);
  static double get availableHeight => _pageFormat.height - (_margin * 2);
  
  /// Captures a widget as an image and converts it to PDF
  /// This method takes a GlobalKey attached to the template widget
  /// and creates a PDF that looks exactly like the template
  static Future<File> convertTemplateToPdf({
    required GlobalKey widgetKey,
    required String templateName,
    required String templateType,
  }) async {
    try {
      // Capture the widget as an image
      final RenderRepaintBoundary boundary =
          widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imageBytes = byteData!.buffer.asUint8List();
      
      // Create PDF document
      final pdf = pw.Document();
      
      // Load the image into PDF format
      final pdfImage = pw.MemoryImage(imageBytes);
      
      // Calculate scaling to fit the image within PDF page bounds
      final double imageAspectRatio = image.width / image.height;
      final double pageAspectRatio = availableWidth / availableHeight;
      
      double pdfImageWidth, pdfImageHeight;
      
      if (imageAspectRatio > pageAspectRatio) {
        // Image is wider than page ratio - fit to width
        pdfImageWidth = availableWidth;
        pdfImageHeight = availableWidth / imageAspectRatio;
      } else {
        // Image is taller than page ratio - fit to height  
        pdfImageHeight = availableHeight;
        pdfImageWidth = availableHeight * imageAspectRatio;
      }
      
      // Add page with the captured template image
      pdf.addPage(
        pw.Page(
          pageFormat: _pageFormat,
          margin: pw.EdgeInsets.all(_margin),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pdfImage,
                width: pdfImageWidth,
                height: pdfImageHeight,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
      
      // Save the PDF file
      return await _savePdfFile(pdf, templateName, templateType);
    } catch (e) {
      throw Exception('Failed to convert template to PDF: $e');
    }
  }
  
  /// Converts a scrollable template to multi-page PDF
  /// This method handles long templates by taking multiple screenshots
  /// and distributing them across multiple PDF pages
  static Future<File> convertScrollableTemplateToPdf({
    required GlobalKey scrollableKey,
    required String templateName,
    required String templateType,
    double? scrollableHeight,
  }) async {
    try {
      final RenderObject? renderObject = scrollableKey.currentContext?.findRenderObject();
      if (renderObject == null) {
        throw Exception('Could not find render object for scrollable template');
      }
      
      final pdf = pw.Document();
      
      // Get the scrollable widget
      final ScrollableState? scrollableState = 
          scrollableKey.currentContext?.findAncestorStateOfType<ScrollableState>();
      
      if (scrollableState != null) {
        // Handle scrollable content by capturing multiple sections
        await _captureScrollablePages(pdf, scrollableState, renderObject as RenderRepaintBoundary);
      } else {
        // Fallback: capture as single page
        final ui.Image image = await (renderObject as RenderRepaintBoundary).toImage(pixelRatio: 2.0);
        await _addImageToPdf(pdf, image);
      }
      
      return await _savePdfFile(pdf, templateName, templateType);
    } catch (e) {
      throw Exception('Failed to convert scrollable template to PDF: $e');
    }
  }
  
  /// Advanced method for converting complex templates with multiple sections
  /// This allows for better control over how different parts of the template are captured
  static Future<File> convertSectionsToPdf({
    required List<GlobalKey> sectionKeys,
    required String templateName,
    required String templateType,
  }) async {
    try {
      final pdf = pw.Document();
      
      for (int i = 0; i < sectionKeys.length; i++) {
        final key = sectionKeys[i];
        final RenderRepaintBoundary? boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        
        if (boundary != null) {
          final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
          await _addImageToPdf(pdf, image);
        }
      }
      
      return await _savePdfFile(pdf, templateName, templateType);
    } catch (e) {
      throw Exception('Failed to convert template sections to PDF: $e');
    }
  }
  
  /// Helper method to capture multiple pages from a scrollable widget
  static Future<void> _captureScrollablePages(
    pw.Document pdf,
    ScrollableState scrollableState,
    RenderRepaintBoundary boundary,
  ) async {
    final ScrollController controller = scrollableState.widget.controller ?? ScrollController();
    final double maxScroll = controller.position.maxScrollExtent;
    final double viewportHeight = controller.position.viewportDimension;
    
    double currentScroll = 0.0;
    
    while (currentScroll <= maxScroll) {
      // Scroll to current position
      controller.jumpTo(currentScroll);
      
      // Wait for rendering to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Capture current view
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      await _addImageToPdf(pdf, image);
      
      // Move to next section
      currentScroll += viewportHeight * 0.8; // 80% overlap to avoid missing content
    }
  }
  
  /// Helper method to add an image to PDF with proper scaling
  static Future<void> _addImageToPdf(pw.Document pdf, ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes = byteData!.buffer.asUint8List();
    final pdfImage = pw.MemoryImage(imageBytes);
    
    // Calculate scaling
    final double imageAspectRatio = image.width / image.height;
    final double pageAspectRatio = availableWidth / availableHeight;
    
    double pdfImageWidth, pdfImageHeight;
    
    if (imageAspectRatio > pageAspectRatio) {
      pdfImageWidth = availableWidth;
      pdfImageHeight = availableWidth / imageAspectRatio;
    } else {
      pdfImageHeight = availableHeight;
      pdfImageWidth = availableHeight * imageAspectRatio;
    }
    
    pdf.addPage(
      pw.Page(
        pageFormat: _pageFormat,
        margin: pw.EdgeInsets.all(_margin),
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(
              pdfImage,
              width: pdfImageWidth,
              height: pdfImageHeight,
              fit: pw.BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
  
  /// Helper method to save PDF file to device storage
  static Future<File> _savePdfFile(
    pw.Document pdf,
    String templateName,
    String templateType,
  ) async {
    try {
      // Try to get external storage directory first (more accessible to users)
      Directory? externalDir;
      
      try {
        // Try to get Downloads directory (most accessible)
        if (Platform.isAndroid) {
          externalDir = Directory('/storage/emulated/0/Download/Digital Planner');
        }
        
        // If external directory doesn't work or we're not on Android, use documents
        if (externalDir == null || !await externalDir.exists()) {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          externalDir = Directory('${appDocDir.path}/Digital Planner');
        }
      } catch (e) {
        // Fallback to app documents directory
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        externalDir = Directory('${appDocDir.path}/Digital Planner');
      }
      
      // Create the Digital Planner folder
      if (!await externalDir.exists()) {
        await externalDir.create(recursive: true);
      }
      
      // Generate filename with timestamp to avoid conflicts
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String sanitizedName = templateName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final String filename = '${sanitizedName}_$timestamp.pdf';
      
      // Save the PDF file
      final File file = File('${externalDir.path}/$filename');
      final Uint8List pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);
      
      return file;
    } catch (e) {
      // Final fallback to temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String sanitizedName = templateName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final String filename = '${sanitizedName}_$timestamp.pdf';
      
      final File file = File('${tempDir.path}/$filename');
      final Uint8List pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);
      
      return file;
    }
  }
  
  /// Export PDF (save only, no share dialog)
  static Future<File> exportTemplateToPdf({
    required GlobalKey widgetKey,
    required String templateName,
    required String templateType,
  }) async {
    try {
      return await convertTemplateToPdf(
        widgetKey: widgetKey,
        templateName: templateName,
        templateType: templateType,
      );
    } catch (e) {
      throw Exception('Failed to export template PDF: $e');
    }
  }
  
  /// Export scrollable PDF (save only, no share dialog)
  static Future<File> exportScrollableTemplateToPdf({
    required GlobalKey scrollableKey,
    required String templateName,
    required String templateType,
  }) async {
    try {
      return await convertScrollableTemplateToPdf(
        scrollableKey: scrollableKey,
        templateName: templateName,
        templateType: templateType,
      );
    } catch (e) {
      throw Exception('Failed to export scrollable template PDF: $e');
    }
  }

  /// Share the PDF file using the platform's share functionality
  static Future<void> shareTemplatePdf({
    required GlobalKey widgetKey,
    required String templateName,
    required String templateType,
  }) async {
    try {
      final File pdfFile = await convertTemplateToPdf(
        widgetKey: widgetKey,
        templateName: templateName,
        templateType: templateType,
      );
      
      final Uint8List pdfBytes = await pdfFile.readAsBytes();
      
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${templateName}_$templateType.pdf',
      );
    } catch (e) {
      throw Exception('Failed to share template PDF: $e');
    }
  }
  
  /// Share a scrollable template as multi-page PDF
  static Future<void> shareScrollableTemplatePdf({
    required GlobalKey scrollableKey,
    required String templateName,
    required String templateType,
  }) async {
    try {
      final File pdfFile = await convertScrollableTemplateToPdf(
        scrollableKey: scrollableKey,
        templateName: templateName,
        templateType: templateType,
      );
      
      final Uint8List pdfBytes = await pdfFile.readAsBytes();
      
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${templateName}_$templateType.pdf',
      );
    } catch (e) {
      throw Exception('Failed to share scrollable template PDF: $e');
    }
  }
  
  /// Print the PDF directly
  static Future<void> printTemplatePdf({
    required GlobalKey widgetKey,
    required String templateName,
    required String templateType,
  }) async {
    try {
      final File pdfFile = await convertTemplateToPdf(
        widgetKey: widgetKey,
        templateName: templateName,
        templateType: templateType,
      );
      
      final Uint8List pdfBytes = await pdfFile.readAsBytes();
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      throw Exception('Failed to print template PDF: $e');
    }
  }
  
  /// Get the path where PDFs are saved
  static Future<String> getPdfSaveDirectory() async {
    try {
      // Try to get the same directory structure as _savePdfFile
      Directory? externalDir;
      
      try {
        if (Platform.isAndroid) {
          externalDir = Directory('/storage/emulated/0/Download/Digital Planner');
        }
        
        if (externalDir == null || !await externalDir.exists()) {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          externalDir = Directory('${appDocDir.path}/Digital Planner');
        }
      } catch (e) {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        externalDir = Directory('${appDocDir.path}/Digital Planner');
      }
      
      return externalDir.path;
    } catch (e) {
      final Directory tempDir = await getTemporaryDirectory();
      return tempDir.path;
    }
  }
  
  /// List all saved PDF files
  static Future<List<File>> getSavedPdfFiles() async {
    try {
      final String pdfDirPath = await getPdfSaveDirectory();
      final Directory pdfDir = Directory(pdfDirPath);
      
      if (!await pdfDir.exists()) {
        return [];
      }
      
      final List<FileSystemEntity> files = await pdfDir.list().toList();
      return files
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.pdf'))
          .toList();
    } catch (e) {
      return [];
    }
  }
}