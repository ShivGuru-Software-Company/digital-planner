import 'package:flutter/material.dart';
import '../services/pdf_service.dart';

/// A widget that helps design templates with PDF page dimensions in mind
class PdfLayoutWidget extends StatelessWidget {
  final Widget child;
  final bool showBounds;
  final EdgeInsets? padding;

  const PdfLayoutWidget({
    super.key,
    required this.child,
    this.showBounds = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the aspect ratio based on PDF page dimensions
    const double pdfAspectRatio = 210 / 297; // A4 aspect ratio (width/height)

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dimensions that maintain PDF aspect ratio
        double containerWidth = constraints.maxWidth;
        double containerHeight = containerWidth / pdfAspectRatio;

        // If height exceeds available space, adjust based on height
        if (containerHeight > constraints.maxHeight) {
          containerHeight = constraints.maxHeight;
          containerWidth = containerHeight * pdfAspectRatio;
        }

        return Center(
          child: Container(
            width: containerWidth,
            height: containerHeight,
            decoration: showBounds
                ? BoxDecoration(
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.5),
                      width: 2,
                    ),
                    color: Colors.white,
                  )
                : const BoxDecoration(color: Colors.white),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        );
      },
    );
  }
}

/// A widget that represents a PDF page break indicator
class PdfPageBreak extends StatelessWidget {
  final String? label;

  const PdfPageBreak({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, color: Colors.grey[600], size: 16),
            const SizedBox(width: 8),
            Text(
              label ?? 'Page Break',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A scrollable container that shows content as it would appear across PDF pages
class PdfPreviewContainer extends StatelessWidget {
  final List<Widget> pages;
  final EdgeInsets pageMargin;

  const PdfPreviewContainer({
    super.key,
    required this.pages,
    this.pageMargin = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int i = 0; i < pages.length; i++) ...[
            if (i > 0) const PdfPageBreak(),
            PdfLayoutWidget(
              showBounds: true,
              padding: pageMargin,
              child: pages[i],
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper class to calculate content distribution across PDF pages
class PdfContentDistributor {
  static const double maxContentHeight =
      257; // A4 height minus margins (297 - 40)

  /// Distributes a list of widgets across multiple pages based on estimated heights
  static List<List<Widget>> distributeContent(
    List<Widget> content,
    List<double> estimatedHeights,
  ) {
    final List<List<Widget>> pages = [];
    List<Widget> currentPage = [];
    double currentPageHeight = 0;

    for (int i = 0; i < content.length; i++) {
      final widget = content[i];
      final height = estimatedHeights[i];

      // If adding this widget would exceed page height, start a new page
      if (currentPageHeight + height > maxContentHeight &&
          currentPage.isNotEmpty) {
        pages.add(List.from(currentPage));
        currentPage = [widget];
        currentPageHeight = height;
      } else {
        currentPage.add(widget);
        currentPageHeight += height;
      }
    }

    // Add the last page if it has content
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    return pages;
  }

  /// Estimates the height of common widget types
  static double estimateWidgetHeight(Widget widget) {
    if (widget is Text) {
      return 20; // Approximate text height
    } else if (widget is Container) {
      return 40; // Default container height
    } else if (widget is ListTile) {
      return 56; // Standard ListTile height
    } else if (widget is Card) {
      return 80; // Approximate card height
    }
    return 30; // Default height for unknown widgets
  }
}
