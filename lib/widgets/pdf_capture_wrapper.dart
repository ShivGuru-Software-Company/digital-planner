import 'package:flutter/material.dart';
import '../services/template_to_pdf_service.dart';

/// A wrapper widget that enables any template to be captured as PDF
/// This widget wraps template content and provides PDF export functionality
class PdfCaptureWrapper extends StatefulWidget {
  final Widget child;
  final String templateName;
  final String templateType;
  final bool isScrollable;
  
  const PdfCaptureWrapper({
    super.key,
    required this.child,
    required this.templateName,
    required this.templateType,
    this.isScrollable = false,
  });

  @override
  State<PdfCaptureWrapper> createState() => _PdfCaptureWrapperState();
}

class _PdfCaptureWrapperState extends State<PdfCaptureWrapper> {
  final GlobalKey _captureKey = GlobalKey();
  bool _isExporting = false;

  /// Export the wrapped template as PDF
  Future<void> exportToPdf() async {
    if (_isExporting) return;
    
    setState(() {
      _isExporting = true;
    });

    try {
      if (widget.isScrollable) {
        await TemplateToPdfService.shareScrollableTemplatePdf(
          scrollableKey: _captureKey,
          templateName: widget.templateName,
          templateType: widget.templateType,
        );
      } else {
        await TemplateToPdfService.shareTemplatePdf(
          widgetKey: _captureKey,
          templateName: widget.templateName,
          templateType: widget.templateType,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF exported successfully! Saved to Digital Planner PDFs folder.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  /// Print the wrapped template
  Future<void> printTemplate() async {
    if (_isExporting) return;
    
    setState(() {
      _isExporting = true;
    });

    try {
      await TemplateToPdfService.printTemplatePdf(
        widgetKey: _captureKey,
        templateName: widget.templateName,
        templateType: widget.templateType,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _captureKey,
      child: widget.child,
    );
  }
}

/// A mixin that provides PDF export functionality to template screens
mixin PdfExportMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey pdfCaptureKey = GlobalKey();
  bool isExportingPdf = false;

  /// Export the current template as PDF
  Future<void> exportTemplateToPdf({
    required String templateName,
    required String templateType,
    bool isScrollable = false,
  }) async {
    if (isExportingPdf) return;
    
    setState(() {
      isExportingPdf = true;
    });

    try {
      if (isScrollable) {
        await TemplateToPdfService.shareScrollableTemplatePdf(
          scrollableKey: pdfCaptureKey,
          templateName: templateName,
          templateType: templateType,
        );
      } else {
        await TemplateToPdfService.shareTemplatePdf(
          widgetKey: pdfCaptureKey,
          templateName: templateName,
          templateType: templateType,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF exported successfully! Check your Digital Planner PDFs folder.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isExportingPdf = false;
        });
      }
    }
  }

  /// Wrap your template content with this method
  Widget buildPdfCapturableContent(Widget content) {
    return RepaintBoundary(
      key: pdfCaptureKey,
      child: Container(
        color: Colors.white, // Ensure white background for PDF
        child: content,
      ),
    );
  }
}

/// Helper widget for adding PDF export button to templates
class PdfExportButton extends StatelessWidget {
  final VoidCallback onExport;
  final bool isLoading;
  final IconData icon;
  final String label;

  const PdfExportButton({
    super.key,
    required this.onExport,
    this.isLoading = false,
    this.icon = Icons.picture_as_pdf,
    this.label = 'Export as PDF',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onExport,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(isLoading ? 'Exporting...' : label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Widget for displaying PDF export options
class PdfExportOptionsDialog extends StatelessWidget {
  final VoidCallback onExportPdf;
  final VoidCallback onPrintPdf;
  final bool isLoading;

  const PdfExportOptionsDialog({
    super.key,
    required this.onExportPdf,
    required this.onPrintPdf,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Options'),
      content: const Text('Choose how you want to export your template:'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: isLoading ? null : () {
            Navigator.of(context).pop();
            onPrintPdf();
          },
          icon: const Icon(Icons.print),
          label: const Text('Print'),
        ),
        ElevatedButton.icon(
          onPressed: isLoading ? null : () {
            Navigator.of(context).pop();
            onExportPdf();
          },
          icon: const Icon(Icons.share),
          label: const Text('Export & Share'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}