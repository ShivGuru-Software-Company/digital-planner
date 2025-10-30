import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class GallerySaveResult {
  final bool success;
  final String? filePath;
  final String? error;

  const GallerySaveResult({required this.success, this.filePath, this.error});
}

class GalleryExportService {
  /// Captures a widget and saves it to gallery
  static Future<GallerySaveResult> saveToGallery({
    required BuildContext context,
    required WidgetBuilder builder,
    double? logicalWidth,
    double pixelRatio = 3.0,
    Color backgroundColor = Colors.white,
    String? fileName,
  }) async {
    try {
      // First capture to local file
      final localResult = await _captureToLocalFile(
        context: context,
        builder: builder,
        logicalWidth: logicalWidth,
        pixelRatio: pixelRatio,
        backgroundColor: backgroundColor,
        fileName: fileName,
        isScrollable: false,
      );

      if (!localResult.success || localResult.filePath == null) {
        return localResult;
      }

      // Then save to gallery
      final file = File(localResult.filePath!);
      final bytes = await file.readAsBytes();

      final name =
          fileName ??
          'digital_planner_${DateTime.now().millisecondsSinceEpoch}.png';
      await Gal.putImageBytes(bytes, name: name);

      return GallerySaveResult(success: true, filePath: localResult.filePath);
    } catch (e) {
      return GallerySaveResult(
        success: false,
        error: 'Capture failed: ${e.toString()}',
      );
    }
  }

  /// Captures scrollable content and saves it to gallery
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
      // First capture to local file
      final localResult = await _captureToLocalFile(
        context: context,
        builder: builder,
        logicalWidth: logicalWidth,
        pixelRatio: pixelRatio,
        backgroundColor: backgroundColor,
        fileName: fileName,
        isScrollable: true,
        fixedHeight: fixedHeight,
      );

      if (!localResult.success || localResult.filePath == null) {
        return localResult;
      }

      // Then save to gallery
      final file = File(localResult.filePath!);
      final bytes = await file.readAsBytes();

      final name =
          fileName ??
          'digital_planner_${DateTime.now().millisecondsSinceEpoch}.png';
      await Gal.putImageBytes(bytes, name: name);

      return GallerySaveResult(success: true, filePath: localResult.filePath);
    } catch (e) {
      return GallerySaveResult(
        success: false,
        error: 'Capture failed: ${e.toString()}',
      );
    }
  }

  /// Captures a widget to local file only (for sharing)
  static Future<GallerySaveResult> captureToLocalFile({
    required BuildContext context,
    required WidgetBuilder builder,
    double? logicalWidth,
    double? fixedHeight,
    double pixelRatio = 3.0,
    Color backgroundColor = Colors.white,
    String? fileName,
    bool isScrollable = false,
  }) async {
    return await _captureToLocalFile(
      context: context,
      builder: builder,
      logicalWidth: logicalWidth,
      pixelRatio: pixelRatio,
      backgroundColor: backgroundColor,
      fileName: fileName,
      isScrollable: isScrollable,
      fixedHeight: fixedHeight,
    );
  }

  /// Internal method to capture widget to local file
  static Future<GallerySaveResult> _captureToLocalFile({
    required BuildContext context,
    required WidgetBuilder builder,
    double? logicalWidth,
    double pixelRatio = 3.0,
    Color backgroundColor = Colors.white,
    String? fileName,
    bool isScrollable = false,
    double? fixedHeight,
  }) async {
    try {
      final mq = MediaQuery.of(context);
      final width = logicalWidth ?? mq.size.width;

      final GlobalKey repaintKey = GlobalKey();

      Widget captureWidget;

      if (isScrollable) {
        final height = fixedHeight ?? 800.0;
        captureWidget = RepaintBoundary(
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
      } else {
        captureWidget = RepaintBoundary(
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
      }

      final overlayState = Overlay.of(context);
      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (context) =>
            Positioned(left: -5000, top: -5000, child: captureWidget),
      );

      overlayState.insert(entry);

      // Wait for rendering
      await Future.delayed(const Duration(milliseconds: 300));

      for (int i = 0; i < 8; i++) {
        await WidgetsBinding.instance.endOfFrame;
        await Future.delayed(const Duration(milliseconds: 16));
      }

      await Future.delayed(const Duration(milliseconds: 200));

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

      // Save to local file
      final directory = await getApplicationDocumentsDirectory();
      final name =
          fileName ??
          'digital_planner_${DateTime.now().millisecondsSinceEpoch}';
      final file = File('${directory.path}/$name.png');

      await file.writeAsBytes(pngBytes);

      return GallerySaveResult(success: true, filePath: file.path);
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
      await Future.delayed(const Duration(milliseconds: 300));

      final renderObject = repaintBoundaryKey.currentContext
          ?.findRenderObject();

      if (renderObject is! RenderRepaintBoundary) {
        return const GallerySaveResult(
          success: false,
          error: 'Invalid RepaintBoundary key',
        );
      }

      final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return const GallerySaveResult(
          success: false,
          error: 'Failed to convert image to bytes',
        );
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to local file first
      final directory = await getApplicationDocumentsDirectory();
      final name =
          fileName ??
          'digital_planner_${DateTime.now().millisecondsSinceEpoch}';
      final file = File('${directory.path}/$name.png');

      await file.writeAsBytes(pngBytes);

      // Then save to gallery
      await Gal.putImageBytes(pngBytes, name: '$name.png');

      return GallerySaveResult(success: true, filePath: file.path);
    } catch (e) {
      return GallerySaveResult(success: false, error: e.toString());
    }
  }
}
