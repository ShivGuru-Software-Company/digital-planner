import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'gallery_export_service.dart';

class TemplateShareService {
  /// Share a template as an image without saving to gallery
  static Future<void> shareTemplate({
    required BuildContext context,
    required String templateName,
    required String dateInfo,
    required WidgetBuilder builder,
    double? fixedHeight,
    double pixelRatio = 3.0,
  }) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Text('Preparing to share...')),
    );

    try {
      // Create a local file for sharing (not saved to gallery)
      final result = await GalleryExportService.captureToLocalFile(
        context: context,
        fileName:
            'share_${templateName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
        builder: builder,
        fixedHeight: fixedHeight,
        isScrollable: fixedHeight != null,
        pixelRatio: pixelRatio,
      );

      scaffold.hideCurrentSnackBar();
      if (!context.mounted) return;

      if (result.success && result.filePath != null) {
        final file = File(result.filePath!);

        if (await file.exists()) {
          // Share the file directly
          await Share.shareXFiles([
            XFile(file.path),
          ], text: 'Check out my $templateName for $dateInfo');

          // Clean up the file after a delay to allow sharing to complete
          Future.delayed(const Duration(seconds: 5), () async {
            try {
              if (await file.exists()) {
                await file.delete();
              }
            } catch (e) {
              // Ignore cleanup errors
            }
          });
        } else {
          throw Exception('Generated image file not found');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to prepare share: ${result.error}')),
        );
      }
    } catch (e) {
      scaffold.hideCurrentSnackBar();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  /// Save template to gallery
  static Future<void> saveTemplateToGallery({
    required BuildContext context,
    required String templateName,
    required String fileName,
    required WidgetBuilder builder,
    double? fixedHeight,
    double pixelRatio = 3.0,
  }) async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(const SnackBar(content: Text('Exporting image...')));

    final result = fixedHeight != null
        ? await GalleryExportService.saveScrollableToGallery(
            context: context,
            fileName: fileName,
            fixedHeight: fixedHeight,
            builder: builder,
            pixelRatio: pixelRatio,
          )
        : await GalleryExportService.saveToGallery(
            context: context,
            fileName: fileName,
            builder: builder,
            pixelRatio: pixelRatio,
          );

    scaffold.hideCurrentSnackBar();
    if (!context.mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to gallery successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${result.error}')),
      );
    }
  }
}
