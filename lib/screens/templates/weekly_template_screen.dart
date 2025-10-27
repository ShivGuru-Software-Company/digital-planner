import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/template_model.dart';
import '../../models/saved_template_model.dart';
import '../../database/database_helper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/save_template_dialog.dart';
import '../../widgets/pdf_capture_wrapper.dart';

class WeeklyTemplateScreen extends StatefulWidget {
  final PlannerTemplate template;
  final TemplateData? existingData;

  const WeeklyTemplateScreen({
    super.key,
    required this.template,
    this.existingData,
  });

  @override
  State<WeeklyTemplateScreen> createState() => _WeeklyTemplateScreenState();
}

class _WeeklyTemplateScreenState extends State<WeeklyTemplateScreen> with PdfExportMixin {
  late DateTime _weekStartDate;
  late DateTime _weekEndDate;
  final Map<String, List<TextEditingController>> _dayControllers = {};
  final Map<String, List<bool>> _dayCheckboxes = {};

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _initializeWeek();
    _initializeControllers();

    if (widget.existingData != null) {
      _loadExistingData();
    }
  }

  void _initializeWeek() {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - 1;
    _weekStartDate = now.subtract(Duration(days: daysFromMonday));
    _weekEndDate = _weekStartDate.add(const Duration(days: 6));
  }

  void _initializeControllers() {
    for (String day in _weekDays) {
      _dayControllers[day] = List.generate(
        5,
        (index) => TextEditingController(),
      );
      _dayCheckboxes[day] = List.generate(5, (index) => false);
    }
  }

  void _loadExistingData() {
    final data = widget.existingData!.data;
    _weekStartDate = DateTime.parse(
      data['weekStartDate'] ?? DateTime.now().toIso8601String(),
    );
    _weekEndDate = DateTime.parse(
      data['weekEndDate'] ?? DateTime.now().toIso8601String(),
    );

    for (String day in _weekDays) {
      final dayData = data[day] as Map<String, dynamic>? ?? {};
      final tasks = dayData['tasks'] as List<dynamic>? ?? [];
      final status = dayData['status'] as List<dynamic>? ?? [];

      for (int i = 0; i < tasks.length && i < 5; i++) {
        _dayControllers[day]![i].text = tasks[i];
        if (i < status.length) _dayCheckboxes[day]![i] = status[i];
      }
    }
  }

  @override
  void dispose() {
    for (var dayControllers in _dayControllers.values) {
      for (var controller in dayControllers) {
        controller.dispose();
      }
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
        child: buildPdfCapturableContent(
          Column(
            children: [
              _buildWeekHeader(),
              Expanded(child: _buildWeekGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekHeader() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Week Overview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _selectWeekStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.template.colors,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Change Week',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '${DateFormat('MMM dd').format(_weekStartDate)} - ${DateFormat('MMM dd, yyyy').format(_weekEndDate)}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: _weekDays.length,
        itemBuilder: (context, index) {
          final day = _weekDays[index];
          final dayDate = _weekStartDate.add(Duration(days: index));

          return GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: widget.template.colors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day.substring(0, 3),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          DateFormat('dd').format(dayDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 4, // Reduced from 5 to 4 tasks
                      itemBuilder: (context, taskIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              Transform.scale(
                                scale: 0.7,
                                child: Checkbox(
                                  value: _dayCheckboxes[day]![taskIndex],
                                  onChanged: (value) {
                                    setState(() {
                                      _dayCheckboxes[day]![taskIndex] =
                                          value ?? false;
                                    });
                                  },
                                  activeColor: widget.template.colors.first,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _dayControllers[day]![taskIndex],
                                  decoration: InputDecoration(
                                    hintText: 'Task ${taskIndex + 1}',
                                    hintStyle: const TextStyle(fontSize: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectWeekStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _weekStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _weekStartDate = date;
        _weekEndDate = date.add(const Duration(days: 6));
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
    final templateName = widget.template.name + ' - Week ${_getWeekOfYear()}';
    await exportTemplateToPdf(
      templateName: templateName,
      templateType: 'Weekly',
      isScrollable: true,
    );
  }
  
  int _getWeekOfYear() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return ((dayOfYear - DateTime.now().weekday + 10) / 7).floor();
  }

  void _shareTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share Template - Coming Soon!')),
    );
  }

  Map<String, dynamic> _collectTemplateData() {
    final data = <String, dynamic>{
      'weekStartDate': _weekStartDate.toIso8601String(),
      'weekEndDate': _weekEndDate.toIso8601String(),
    };

    for (String day in _weekDays) {
      data[day] = {
        'tasks': _dayControllers[day]!.map((c) => c.text).toList(),
        'status': _dayCheckboxes[day],
      };
    }

    return data;
  }

  Future<void> _saveTemplate() async {
    // Show save dialog to get custom name
    final customName = await _showSaveDialog();
    if (customName == null) return; // User cancelled

    await _performSave(customName);
  }

  Future<String?> _showSaveDialog() async {
    final defaultName =
        '${widget.template.name} - ${DateFormat('MMM dd').format(_weekStartDate)}';

    return await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SaveTemplateDialog(
              defaultName: defaultName,
              templateType: 'Weekly',
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _performSave(String customName) async {
    final data = <String, dynamic>{
      'weekStartDate': _weekStartDate.toIso8601String(),
      'weekEndDate': _weekEndDate.toIso8601String(),
    };

    for (String day in _weekDays) {
      data[day] = {
        'tasks': _dayControllers[day]!.map((c) => c.text).toList(),
        'status': _dayCheckboxes[day],
      };
    }

    try {
      final databaseHelper = DatabaseHelper();

      if (widget.existingData != null) {
        final existingTemplates = await databaseHelper.getAllSavedTemplates();
        final existingTemplate = existingTemplates.firstWhere(
          (t) =>
              t.templateId == widget.template.id &&
              t.updatedAt.isAfter(
                _weekStartDate.subtract(const Duration(days: 7)),
              ) &&
              t.updatedAt.isBefore(_weekEndDate.add(const Duration(days: 7))),
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
          const SnackBar(content: Text('Weekly template saved successfully!')),
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
