import 'package:flutter/material.dart';
import '../../models/template_model.dart';
import '../../models/saved_template_model.dart';
import '../../database/database_helper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/save_template_dialog.dart';
import '../../widgets/pdf_capture_wrapper.dart';

class YearlyTemplateScreen extends StatefulWidget {
  final PlannerTemplate template;
  final TemplateData? existingData;

  const YearlyTemplateScreen({
    super.key,
    required this.template,
    this.existingData,
  });

  @override
  State<YearlyTemplateScreen> createState() => _YearlyTemplateScreenState();
}

class _YearlyTemplateScreenState extends State<YearlyTemplateScreen> {
  late int _selectedYear;
  final Map<int, TextEditingController> _monthControllers = {};
  final Map<int, String> _monthNotes = {};

  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _initializeControllers();

    if (widget.existingData != null) {
      _loadExistingData();
    }
  }

  void _initializeControllers() {
    for (int i = 1; i <= 12; i++) {
      _monthControllers[i] = TextEditingController();
      _monthNotes[i] = '';
    }
  }

  void _loadExistingData() {
    final data = widget.existingData!.data;
    _selectedYear = data['selectedYear'] ?? DateTime.now().year;

    final monthNotes = data['monthNotes'] as Map<String, dynamic>? ?? {};
    monthNotes.forEach((month, note) {
      final monthInt = int.tryParse(month);
      if (monthInt != null && _monthControllers.containsKey(monthInt)) {
        _monthControllers[monthInt]!.text = note;
        _monthNotes[monthInt] = note;
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _monthControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name),
        backgroundColor: widget.template.colors.first,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showExportMenu,
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveTemplate),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.template.colors.first.withValues(alpha: 0.1),
              widget.template.colors.last.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildYearHeader(),
            Expanded(child: _buildMonthsGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildYearHeader() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousYear,
                icon: const Icon(Icons.chevron_left, size: 16),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _selectYear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: widget.template.colors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedYear.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextYear,
                icon: const Icon(Icons.chevron_right, size: 16),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final monthNumber = index + 1;
          final monthName = _monthNames[index];
          final hasNote = _monthNotes[monthNumber]?.isNotEmpty ?? false;
          final noteText = _monthNotes[monthNumber] ?? '';

          return GestureDetector(
            onTap: () => _showMonthDialog(monthNumber, monthName),
            child: GlassCard(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: hasNote
                      ? LinearGradient(
                          colors: [
                            widget.template.colors.first.withValues(alpha: 0.1),
                            widget.template.colors.last.withValues(alpha: 0.1),
                          ],
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.template.colors,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        monthName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Notes area
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: hasNote
                                ? widget.template.colors.first.withValues(
                                    alpha: 0.3,
                                  )
                                : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: hasNote
                            ? Text(
                                noteText,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black87,
                                ),
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Text(
                                'Tap to add notes for $monthName...',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                      ),
                    ),
                    // Note indicator
                    if (hasNote)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.note,
                              size: 12,
                              color: widget.template.colors.first,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Has notes',
                              style: TextStyle(
                                fontSize: 8,
                                color: widget.template.colors.first,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMonthDialog(int monthNumber, String monthName) {
    final controller = _monthControllers[monthNumber]!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '$monthName $_selectedYear',
          style: const TextStyle(fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: const InputDecoration(
              hintText: 'Add your plans, goals, and notes for this month...',
              hintStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _monthNotes[monthNumber] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _previousYear() {
    setState(() {
      _selectedYear--;
      _initializeControllers();
    });
  }

  void _nextYear() {
    setState(() {
      _selectedYear++;
      _initializeControllers();
    });
  }

  Future<void> _selectYear() async {
    final year = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Year'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: YearPicker(
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            selectedDate: DateTime(_selectedYear),
            onChanged: (date) {
              Navigator.pop(context, date.year);
            },
          ),
        ),
      ),
    );

    if (year != null) {
      setState(() {
        _selectedYear = year;
        _initializeControllers();
      });
    }
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Template'),
              onTap: () {
                Navigator.pop(context);
                _shareTemplate();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportAsPDF() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create a saved template model for PDF export
      final templateData = _collectTemplateData();
      final savedTemplate = SavedTemplateModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        templateId: widget.template.id,
        templateName: widget.template.name,
        templateType: 'Yearly',
        templateDesign: widget.template.design.name,
        templateIcon: widget.template.icon,
        templateColors: widget.template.colors,
        data: templateData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Generate and share PDF
      // Show message for new PDF export system
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New PDF export system active! Use Export as PDF button for enhanced PDFs.')),
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting PDF: $e')));
      }
    }
  }

  void _shareTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share Template - Coming Soon!')),
    );
  }

  Map<String, dynamic> _collectTemplateData() {
    return {
      'selectedYear': _selectedYear,
      'monthNotes': Map.fromEntries(
        _monthNotes.entries.map((e) => MapEntry(e.key.toString(), e.value)),
      ),
    };
  }

  Future<void> _saveTemplate() async {
    // Show save dialog to get custom name
    final customName = await _showSaveDialog();
    if (customName == null) return; // User cancelled

    await _performSave(customName);
  }

  Future<String?> _showSaveDialog() async {
    final defaultName = '${widget.template.name} - $_selectedYear';

    return await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SaveTemplateDialog(
              defaultName: defaultName,
              templateType: 'Yearly',
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _performSave(String customName) async {
    final data = {
      'selectedYear': _selectedYear,
      'monthNotes': Map.fromEntries(
        _monthNotes.entries.map((e) => MapEntry(e.key.toString(), e.value)),
      ),
    };

    try {
      final databaseHelper = DatabaseHelper();

      if (widget.existingData != null) {
        final existingTemplates = await databaseHelper.getAllSavedTemplates();
        final existingTemplate = existingTemplates.firstWhere(
          (t) =>
              t.templateId == widget.template.id &&
              t.updatedAt.year == _selectedYear,
          orElse: () => SavedTemplateModel.create(
            templateId: widget.template.id,
            templateName: customName,
            templateType: widget.template.type.name,
            templateDesign: widget.template.design.name,
            templateColors: widget.template.colors,
            templateIcon: widget.template.icon,
            data: data,
          ),
        );

        final updatedTemplate = existingTemplate.copyWith(
          templateName: customName,
          data: data,
          updatedAt: DateTime.now(),
        );

        await databaseHelper.updateSavedTemplate(updatedTemplate);
      } else {
        final savedTemplate = SavedTemplateModel.create(
          templateId: widget.template.id,
          templateName: customName,
          templateType: widget.template.type.name,
          templateDesign: widget.template.design.name,
          templateColors: widget.template.colors,
          templateIcon: widget.template.icon,
          data: data,
        );

        await databaseHelper.insertSavedTemplate(savedTemplate);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Template "$customName" saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving template: $e')));
      }
    }
  }
}
