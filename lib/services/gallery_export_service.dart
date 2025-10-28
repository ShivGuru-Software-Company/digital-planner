import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:flutter/rendering.dart';

class GallerySaveResult {
  final bool success;
  final String? filePath;
  final String? error;

  const GallerySaveResult({required this.success, this.filePath, this.error});
}

class GalleryExportService {
  /// Final, most reliable method for capturing widgets
  static Future<GallerySaveResult> saveToGallery({
    required BuildContext context,
    required WidgetBuilder builder,
    double? logicalWidth,
    double pixelRatio = 3.0,
    Color backgroundColor = Colors.white,
    String? fileName,
  }) async {
    try {
      final mq = MediaQuery.of(context);
      final width = logicalWidth ?? mq.size.width;

      // Create a simple GlobalKey for RepaintBoundary
      final GlobalKey repaintKey = GlobalKey();

      // Create the widget to capture
      final captureWidget = RepaintBoundary(
        key: repaintKey,
        child: Container(
          width: width,
          color: backgroundColor,
          child: Material(
            color: Colors.transparent,
            child: MediaQuery(
              data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: builder(context),
              ),
            ),
          ),
        ),
      );

      // Show in a temporary overlay positioned far off-screen
      final overlayState = Overlay.of(context);
      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (context) => Positioned(
          left: -5000, // Far off-screen
          top: -5000,
          child: captureWidget,
        ),
      );

      overlayState.insert(entry);

      // Wait for the widget to be fully built and rendered
      await Future.delayed(const Duration(milliseconds: 300));

      // Wait for multiple frame cycles to ensure complete rendering
      for (int i = 0; i < 8; i++) {
        await WidgetsBinding.instance.endOfFrame;
        await Future.delayed(const Duration(milliseconds: 16));
      }

      // Additional wait to ensure everything is settled
      await Future.delayed(const Duration(milliseconds: 200));

      // Get the render object
      final renderObject = repaintKey.currentContext?.findRenderObject();

      if (renderObject is! RenderRepaintBoundary) {
        entry.remove();
        return const GallerySaveResult(
          success: false,
          error: 'Could not find RepaintBoundary render object',
        );
      }

      // Capture the image - no paint checks, just capture
      final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);

      // Remove the overlay immediately after capture
      entry.remove();

      // Convert to PNG bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return const GallerySaveResult(
          success: false,
          error: 'Failed to convert image to PNG bytes',
        );
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to gallery
      final name =
          fileName ??
          'digital_planner_${DateTime.now().millisecondsSinceEpoch}.png';
      await Gal.putImageBytes(pngBytes, name: name);

      return GallerySaveResult(success: true, filePath: name);
    } catch (e) {
      return GallerySaveResult(
        success: false,
        error: 'Capture failed: ${e.toString()}',
      );
    }
  }

  /// Method for scrollable content with fixed height
  static Future<GallerySaveResult> saveScrollableToGallery({
    required BuildContext context,
    required WidgetBuilder builder,
    double? logicalWidth,
    double? fixedHeight,
    double pixelRatio = 3.0,
    Color backgroundColor = Colors.white,
    String? fileName,
  }) async {
    try {
      final mq = MediaQuery.of(context);
      final width = logicalWidth ?? mq.size.width;
      final height = fixedHeight ?? 800.0; // Reasonable default height

      final GlobalKey repaintKey = GlobalKey();

      final captureWidget = RepaintBoundary(
        key: repaintKey,
        child: Container(
          width: width,
          height: height,
          color: backgroundColor,
          child: Material(
            color: Colors.transparent,
            child: MediaQuery(
              data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: builder(context),
                ),
              ),
            ),
          ),
        ),
      );

      final overlayState = Overlay.of(context);
      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (context) =>
            Positioned(left: -5000, top: -5000, child: captureWidget),
      );

      overlayState.insert(entry);

      // Wait longer for scrollable content
      await Future.delayed(const Duration(milliseconds: 400));

      for (int i = 0; i < 10; i++) {
        await WidgetsBinding.instance.endOfFrame;
        await Future.delayed(const Duration(milliseconds: 20));
      }

      await Future.delayed(const Duration(milliseconds: 300));

      final renderObject = repaintKey.currentContext?.findRenderObject();

      if (renderObject is! RenderRepaintBoundary) {
        entry.remove();
        return const GallerySaveResult(
          success: false,
          error: 'Could not find RepaintBoundary render object',
        );
      }

      final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
      entry.remove();

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return const GallerySaveResult(
          success: false,
          error: 'Failed to convert image to PNG bytes',
        );
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final name =
          fileName ??
          'digital_planner_${DateTime.now().millisecondsSinceEpoch}.png';
      await Gal.putImageBytes(pngBytes, name: name);

      return GallerySaveResult(success: true, filePath: name);
    } catch (e) {
      return GallerySaveResult(
        success: false,
        error: 'Capture failed: ${e.toString()}',
      );
    }
  }

  /// Simple method that captures a widget directly without overlay (for testing)
  static Future<GallerySaveResult> captureWidgetDirectly({
    required GlobalKey repaintBoundaryKey,
    double pixelRatio = 3.0,
    String? fileName,
  }) async {
    try {
      // Wait a moment to ensure the widget is fully rendered
      await Future.delayed(const Duration(milliseconds: 300));

      final renderObject = repaintBoundaryKey.currentContext
          ?.findRenderObject();

      if (renderObject is! RenderRepaintBoundary) {
        return const GallerySaveResult(
          success: false,
          error: 'Invalid RepaintBoundary key',
        );
      }

      // Capture without any paint checks
      final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return const GallerySaveResult(
          success: false,
          error: 'Failed to convert image to bytes',
        );
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final name =
          fileName ??
          'digital_planner_${DateTime.now().millisecondsSinceEpoch}.png';

      await Gal.putImageBytes(pngBytes, name: name);

      return GallerySaveResult(success: true, filePath: name);
    } catch (e) {
      return GallerySaveResult(success: false, error: e.toString());
    }
  }
}
