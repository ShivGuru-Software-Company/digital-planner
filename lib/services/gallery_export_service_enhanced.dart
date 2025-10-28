import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:flutter/rendering.dart';

class GalleryExportServiceEnhanced {
  /// Enhanced gallery export with retry mechanism and better error handling
  static Future<GallerySaveResult> saveToGalleryWithRetry({
    required BuildContext context,
    required WidgetBuilder builder,
    double? logicalWidth,
    double? fixedHeight,
    double pixelRatio = 3.0,
    Color backgroundColor = Colors.white,
    String? fileName,
    int maxRetries = 3,
    bool isScrollable = false,
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final result = isScrollable
            ? await _saveScrollableContent(
                context: context,
                builder: builder,
                logicalWidth: logicalWidth,
                fixedHeight: fixedHeight,
                pixelRatio: pixelRatio,
                backgroundColor: backgroundColor,
                fileName: fileName,
              )
            : await _saveRegularContent(
                context: context,
                builder: builder,
                logicalWidth: logicalWidth,
                pixelRatio: pixelRatio,
                backgroundColor: backgroundColor,
                fileName: fileName,
              );

        if (result.success) {
          return result;
        }

        // If it's a painting error and we have retries left, wait and try again
        if (result.error?.contains('painting') == true &&
            attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
          continue;
        }

        return result;
      } catch (e) {
        if (attempt == maxRetries - 1) {
          return GallerySaveResult(success: false, error: e.toString());
        }
        await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
      }
    }

    return const GallerySaveResult(
      success: false,
      error: 'Failed after maximum retries',
    );
  }

  static Future<GallerySaveResult> _saveRegularContent({
    required BuildContext context,
    required WidgetBuilder builder,
    double? logicalWidth,
    double pixelRatio = 3.0,
    Color backgroundColor = Colors.white,
    String? fileName,
  }) async {
    final overlayState = Overlay.of(context);
    final boundaryKey = GlobalKey();
    final mq = MediaQuery.of(context);
    final width = logicalWidth ?? mq.size.width;

    final entry = OverlayEntry(
      builder: (ctx) => MediaQuery(
        data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
        child: IgnorePointer(
          ignoring: true,
          child: Opacity(
            opacity: 0.0,
            child: Material(
              type: MaterialType.canvas,
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: Container(
                    color: backgroundColor,
                    width: width,
                    child: builder(ctx),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(entry);

    try {
      // Progressive waiting strategy
      await Future.delayed(const Duration(milliseconds: 100));
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 100));

      // Wait for layout to stabilize
      for (int i = 0; i < 5; i++) {
        await WidgetsBinding.instance.endOfFrame;
        await Future.delayed(const Duration(milliseconds: 16));
      }

      final renderObject = boundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        return const GallerySaveResult(
          success: false,
          error: 'Failed to obtain render boundary',
        );
      }

      final boundary = renderObject;

      // Check if ready for capture
      if (boundary.debugNeedsPaint) {
        return const GallerySaveResult(
          success: false,
          error: 'Widget is still painting, please try again',
        );
      }

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return const GallerySaveResult(
          success: false,
          error: 'Failed to encode image bytes',
        );
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final name =
          fileName ??
          'digital_planner_${DateTime.now().millisecondsSinceEpoch}.png';

      await Gal.putImageBytes(pngBytes, name: name);
      return GallerySaveResult(success: true, filePath: name);
    } finally {
      entry.remove();
    }
  }

  static Future<GallerySaveResult> _saveScrollableContent({
    required BuildContext context,
    required WidgetBuilder builder,
    double? logicalWidth,
    double? fixedHeight,
    double pixelRatio = 3.0,
    Color backgroundColor = Colors.white,
    String? fileName,
  }) async {
    final overlayState = Overlay.of(context);
    final boundaryKey = GlobalKey();
    final mq = MediaQuery.of(context);
    final width = logicalWidth ?? mq.size.width;
    final height = fixedHeight ?? mq.size.height * 1.5;

    final entry = OverlayEntry(
      builder: (ctx) => MediaQuery(
        data: mq.copyWith(textScaler: const TextScaler.linear(1.0)),
        child: IgnorePointer(
          ignoring: true,
          child: Opacity(
            opacity: 0.0,
            child: Material(
              type: MaterialType.canvas,
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: Container(
                    color: backgroundColor,
                    width: width,
                    height: height,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: builder(ctx),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(entry);

    try {
      // Longer wait for scrollable content
      await Future.delayed(const Duration(milliseconds: 150));
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 150));

      for (int i = 0; i < 3; i++) {
        await WidgetsBinding.instance.endOfFrame;
        await Future.delayed(const Duration(milliseconds: 33));
      }

      final renderObject = boundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        return const GallerySaveResult(
          success: false,
          error: 'Failed to obtain render boundary',
        );
      }

      final boundary = renderObject;
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return const GallerySaveResult(
          success: false,
          error: 'Failed to encode image bytes',
        );
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final name =
          fileName ??
          'digital_planner_${DateTime.now().millisecondsSinceEpoch}.png';

      await Gal.putImageBytes(pngBytes, name: name);
      return GallerySaveResult(success: true, filePath: name);
    } finally {
      entry.remove();
    }
  }
}

class GallerySaveResult {
  final bool success;
  final String? filePath;
  final String? error;

  const GallerySaveResult({required this.success, this.filePath, this.error});
}
