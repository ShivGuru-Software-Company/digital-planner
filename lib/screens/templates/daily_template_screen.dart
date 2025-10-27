import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/template_model.dart';
import '../../models/saved_template_model.dart';
import '../../database/database_helper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/save_template_dialog.dart';
import '../../widgets/pdf_capture_wrapper.dart';

class DailyTemplateScreen extends StatefulWidget {
  final PlannerTemplate template;
  final TemplateData? existingData;

  const DailyTemplateScreen({
    super.key,
    required this.template,
    this.existingData,
  });

  @override
  State<DailyTemplateScreen> createState() => _DailyTemplateScreenState();
}

class _DailyTemplateScreenState extends State<DailyTemplateScreen> with PdfExportMixin {
  late DateTime _selectedDate;
  String _selectedWeather = '';
  final List<TextEditingController> _priorityControllers = [];
  final List<TextEditingController> _todoControllers = [];
  final List<bool> _todoChecked = [];
  final List<TextEditingController> _taskControllers = [];
  final List<bool> _taskChecked = [];
  final TextEditingController _moneyInController = TextEditingController();
  final TextEditingController _moneyOutController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  int _waterIntake = 0;
  final Map<String, TextEditingController> _scheduleControllers = {};

  final List<String> _weatherOptions = ['☀️', '🌤', '☁️', '🌧'];
  final List<String> _timeSlots = [
    '5:00 AM',
    '6:00 AM',
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    // Initialize controllers
    for (int i = 0; i < 3; i++) {
      _priorityControllers.add(TextEditingController());
    }
    for (int i = 0; i < 4; i++) {
      _todoControllers.add(TextEditingController());
      _todoChecked.add(false);
    }
    for (int i = 0; i < 3; i++) {
      _taskControllers.add(TextEditingController());
      _taskChecked.add(false);
    }
    for (String time in _timeSlots) {
      _scheduleControllers[time] = TextEditingController();
    }

    // Load existing data if available
    if (widget.existingData != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final data = widget.existingData!.data;
    _selectedDate = widget.existingData!.date;
    _selectedWeather = data['weather'] ?? '';
    _waterIntake = data['waterIntake'] ?? 0;

    // Load priorities
    final priorities = data['priorities'] as List<dynamic>? ?? [];
    for (
      int i = 0;
      i < priorities.length && i < _priorityControllers.length;
      i++
    ) {
      _priorityControllers[i].text = priorities[i];
    }

    // Load todos
    final todos = data['todos'] as List<dynamic>? ?? [];
    final todoStatus = data['todoStatus'] as List<dynamic>? ?? [];
    for (int i = 0; i < todos.length && i < _todoControllers.length; i++) {
      _todoControllers[i].text = todos[i];
      if (i < todoStatus.length) _todoChecked[i] = todoStatus[i];
    }

    // Load tasks
    final tasks = data['tasks'] as List<dynamic>? ?? [];
    final taskStatus = data['taskStatus'] as List<dynamic>? ?? [];
    for (int i = 0; i < tasks.length && i < _taskControllers.length; i++) {
      _taskControllers[i].text = tasks[i];
      if (i < taskStatus.length) _taskChecked[i] = taskStatus[i];
    }

    // Load finance
    _moneyInController.text = data['moneyIn'] ?? '';
    _moneyOutController.text = data['moneyOut'] ?? '';
    _commentController.text = data['comment'] ?? '';

    // Load schedule
    final schedule = data['schedule'] as Map<String, dynamic>? ?? {};
    schedule.forEach((time, task) {
      if (_scheduleControllers.containsKey(time)) {
        _scheduleControllers[time]!.text = task;
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _priorityControllers) {
      controller.dispose();
    }
    for (var controller in _todoControllers) {
      controller.dispose();
    }
    for (var controller in _taskControllers) {
      controller.dispose();
    }
    _moneyInController.dispose();
    _moneyOutController.dispose();
    _commentController.dispose();
    for (var controller in _scheduleControllers.values) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Always use single column layout for better responsiveness
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: buildPdfCapturableContent(
                Column(
                  children: [
                    _buildDateSection(),
                    const SizedBox(height: 8),
                    _buildWeatherSection(),
                    const SizedBox(height: 8),
                    _buildPrioritiesSection(),
                    const SizedBox(height: 8),
                    _buildFinanceSection(),
                    const SizedBox(height: 8),
                    _buildWaterTrackerSection(),
                    const SizedBox(height: 8),
                    _buildScheduleSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.template.colors),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Plans & Schedule',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final time = _timeSlots[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          controller: _scheduleControllers[time],
                          decoration: InputDecoration(
                            hintText: 'Task...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 10),
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
    );
  }

  Widget _buildDateSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Today',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.template.colors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _weatherOptions.map((weather) {
                final isSelected = _selectedWeather == weather;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeather = isSelected ? '' : weather;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? widget.template.colors.first
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      color: isSelected
                          ? widget.template.colors.first.withValues(alpha: 0.1)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        weather,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritiesSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Focus",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSubSection('Top 3 Priorities', _priorityControllers, null),
            const SizedBox(height: 8),
            _buildSubSection('To-Do List', _todoControllers, _todoChecked),
            const SizedBox(height: 8),
            _buildSubSection(
              'Things to Get Done',
              _taskControllers,
              _taskChecked,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection(
    String title,
    List<TextEditingController> controllers,
    List<bool>? checkboxes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: widget.template.colors.first,
          ),
        ),
        const SizedBox(height: 4),
        ...List.generate(controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                if (checkboxes != null) ...[
                  Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: checkboxes[index],
                      onChanged: (value) {
                        setState(() {
                          checkboxes[index] = value ?? false;
                        });
                      },
                      activeColor: widget.template.colors.first,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: TextField(
                    controller: controllers[index],
                    decoration: InputDecoration(
                      hintText: checkboxes != null
                          ? 'Add task...'
                          : 'Priority ${index + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFinanceSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Finance',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceInput(
                    '💰',
                    'Money In',
                    _moneyInController,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildFinanceInput(
                    '💸',
                    'Money Out',
                    _moneyOutController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildFinanceInput('💬', 'Comment', _commentController),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceInput(
    String emoji,
    String label,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 11),
      keyboardType: label.contains('Money')
          ? TextInputType.number
          : TextInputType.text,
    );
  }

  Widget _buildWaterTrackerSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Water Tracker',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final isFilled = index < _waterIntake;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _waterIntake = index + 1;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isFilled ? Colors.blue[400] : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? Colors.blue[400]! : Colors.grey[400]!,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.local_drink,
                      color: isFilled ? Colors.white : Colors.grey[400],
                      size: 16,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '$_waterIntake / 7 glasses',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
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
    final templateName = widget.template.name + ' - ${DateFormat('MMM dd, yyyy').format(_selectedDate)}';
    await exportTemplateToPdf(
      templateName: templateName,
      templateType: 'Daily',
      isScrollable: true,
    );
  }

  void _shareTemplate() {
    // TODO: Implement sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share Template - Coming Soon!')),
    );
  }

  Future<void> _saveTemplate() async {
    // Show save dialog to get custom name
    final customName = await _showSaveDialog();
    if (customName == null) return; // User cancelled

    await _performSave(customName);
  }

  Future<String?> _showSaveDialog() async {
    final defaultName =
        '${widget.template.name} - ${DateFormat('MMM dd').format(_selectedDate)}';

    return await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SaveTemplateDialog(defaultName: defaultName, templateType: 'Daily'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _performSave(String customName) async {
    final data = {
      'selectedDate': _selectedDate.toIso8601String(),
      'weather': _selectedWeather,
      'priorities': _priorityControllers.map((c) => c.text).toList(),
      'todos': _todoControllers.map((c) => c.text).toList(),
      'todoStatus': _todoChecked,
      'tasks': _taskControllers.map((c) => c.text).toList(),
      'taskStatus': _taskChecked,
      'moneyIn': _moneyInController.text,
      'moneyOut': _moneyOutController.text,
      'comment': _commentController.text,
      'waterIntake': _waterIntake,
      'schedule': Map.fromEntries(
        _scheduleControllers.entries.map((e) => MapEntry(e.key, e.value.text)),
      ),
    };

    try {
      final databaseHelper = DatabaseHelper();

      // Check if this is an update to existing template
      if (widget.existingData != null) {
        // Find existing template by matching template data
        final existingTemplates = await databaseHelper.getAllSavedTemplates();
        final existingTemplate = existingTemplates.firstWhere(
          (t) =>
              t.templateId == widget.template.id &&
              t.updatedAt.day == _selectedDate.day &&
              t.updatedAt.month == _selectedDate.month &&
              t.updatedAt.year == _selectedDate.year,
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
        // Create new saved template
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
          const SnackBar(content: Text('Template saved successfully!')),
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
