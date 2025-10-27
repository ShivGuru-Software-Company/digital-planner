import 'package:flutter/material.dart';
import 'pdf_layout_widget.dart';

/// A canvas widget designed for template creation with PDF export in mind
class TemplateCanvas extends StatefulWidget {
  final List<Widget> content;
  final String templateTitle;
  final Color? backgroundColor;
  final EdgeInsets? contentPadding;
  final VoidCallback? onContentChanged;

  const TemplateCanvas({
    super.key,
    required this.content,
    required this.templateTitle,
    this.backgroundColor,
    this.contentPadding,
    this.onContentChanged,
  });

  @override
  State<TemplateCanvas> createState() => _TemplateCanvasState();
}

class _TemplateCanvasState extends State<TemplateCanvas> {
  late List<List<Widget>> _pages;
  bool _showPageBounds = false;

  @override
  void initState() {
    super.initState();
    _distributeContentAcrossPages();
  }

  @override
  void didUpdateWidget(TemplateCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _distributeContentAcrossPages();
    }
  }

  void _distributeContentAcrossPages() {
    // Estimate heights for each content widget
    final estimatedHeights = widget.content
        .map((widget) => PdfContentDistributor.estimateWidgetHeight(widget))
        .toList();

    // Distribute content across pages
    _pages = PdfContentDistributor.distributeContent(
      widget.content,
      estimatedHeights,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.templateTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showPageBounds ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[700],
            ),
            onPressed: () {
              setState(() {
                _showPageBounds = !_showPageBounds;
              });
            },
            tooltip: _showPageBounds ? 'Hide page bounds' : 'Show page bounds',
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.grey[700]),
            onPressed: _showPageInfo,
            tooltip: 'Page information',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showPageBounds) _buildPageInfo(),
          Expanded(
            child: PdfPreviewContainer(
              pages: _pages
                  .map((pageContent) => _buildPageContent(pageContent))
                  .toList(),
              pageMargin: widget.contentPadding ?? const EdgeInsets.all(20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Template will be exported as ${_pages.length} PDF page${_pages.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(List<Widget> pageContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pageContent,
    );
  }

  void _showPageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Export Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Template: ${widget.templateTitle}'),
            const SizedBox(height: 8),
            Text('Total pages: ${_pages.length}'),
            const SizedBox(height: 8),
            const Text('Page format: A4 (210 × 297 mm)'),
            const SizedBox(height: 8),
            const Text(
              'Content is automatically distributed across pages to ensure nothing is cut off.',
            ),
            const SizedBox(height: 16),
            const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('• Toggle page bounds to see how content fits'),
            const Text(
              '• Content that doesn\'t fit on one page will flow to the next',
            ),
            const Text('• Export will maintain this exact layout'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// A specialized template canvas for form-based templates
class FormTemplateCanvas extends StatelessWidget {
  final String title;
  final List<FormSection> sections;
  final Color? backgroundColor;

  const FormTemplateCanvas({
    super.key,
    required this.title,
    required this.sections,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[];

    // Add title
    content.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );

    // Add sections
    for (final section in sections) {
      content.addAll(section.buildWidgets());
      content.add(const SizedBox(height: 16));
    }

    return TemplateCanvas(
      content: content,
      templateTitle: title,
      backgroundColor: backgroundColor,
    );
  }
}

/// Represents a section in a form template
class FormSection {
  final String title;
  final List<FormField> fields;
  final EdgeInsets? padding;

  FormSection({required this.title, required this.fields, this.padding});

  List<Widget> buildWidgets() {
    final widgets = <Widget>[];

    // Section title
    widgets.add(
      Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );

    widgets.add(const SizedBox(height: 12));

    // Section fields
    for (final field in fields) {
      widgets.addAll(field.buildWidgets());
      widgets.add(const SizedBox(height: 8));
    }

    return widgets;
  }
}

/// Represents a field in a form section
abstract class FormField {
  final String label;
  final bool isRequired;

  FormField({required this.label, this.isRequired = false});

  List<Widget> buildWidgets();
}

/// A text input field
class TextFormField extends FormField {
  final String? placeholder;
  final int maxLines;
  final TextEditingController? controller;

  TextFormField({
    required super.label,
    super.isRequired,
    this.placeholder,
    this.maxLines = 1,
    this.controller,
  });

  @override
  List<Widget> buildWidgets() {
    return [
      Text(
        label + (isRequired ? ' *' : ''),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: placeholder,
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    ];
  }
}

/// A checkbox field
class CheckboxFormField extends FormField {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  CheckboxFormField({
    required super.label,
    super.isRequired,
    this.value = false,
    this.onChanged,
  });

  @override
  List<Widget> buildWidgets() {
    return [
      Row(
        children: [
          Checkbox(value: value, onChanged: onChanged),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label + (isRequired ? ' *' : ''),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ];
  }
}

/// A list field for multiple items
class ListFormField extends FormField {
  final List<String> items;
  final VoidCallback? onAddItem;
  final Function(int)? onRemoveItem;

  ListFormField({
    required super.label,
    super.isRequired,
    required this.items,
    this.onAddItem,
    this.onRemoveItem,
  });

  @override
  List<Widget> buildWidgets() {
    final widgets = <Widget>[];

    widgets.add(
      Text(
        label + (isRequired ? ' *' : ''),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );

    widgets.add(const SizedBox(height: 8));

    for (int i = 0; i < items.length; i++) {
      widgets.add(
        Row(
          children: [
            const Text('• ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(items[i], style: const TextStyle(fontSize: 14)),
            ),
            if (onRemoveItem != null)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 16),
                onPressed: () => onRemoveItem!(i),
              ),
          ],
        ),
      );
    }

    if (onAddItem != null) {
      widgets.add(
        TextButton.icon(
          onPressed: onAddItem,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add item'),
        ),
      );
    }

    return widgets;
  }
}
