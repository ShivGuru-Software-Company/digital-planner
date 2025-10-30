import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/template_model.dart';
import '../../models/saved_template_model.dart';
import '../../database/database_helper.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/save_template_dialog.dart';
import '../../services/gallery_export_service.dart';
import 'package:share_plus/share_plus.dart';

class MonthlyTemplateScreen extends StatefulWidget {
  final PlannerTemplate template;
  final TemplateData? existingData;

  const MonthlyTemplateScreen({
    super.key,
    required this.template,
    this.existingData,
  });

  @override
  State<MonthlyTemplateScreen> createState() => _MonthlyTemplateScreenState();
}

class _MonthlyTemplateScreenState extends State<MonthlyTemplateScreen> {
  late DateTime _selectedMonth;
  final Map<int, TextEditingController> _dayControllers = {};
  final Map<int, String> _dayNotes = {};

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _initializeControllers();

    if (widget.existingData != null) {
      _loadExistingData();
    }
  }

  void _initializeControllers() {
    final daysInMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    ).day;
    for (int i = 1; i <= daysInMonth; i++) {
      _dayControllers[i] = TextEditingController();
      _dayNotes[i] = '';
    }
  }

  void _loadExistingData() {
    final data = widget.existingData!.data;
    _selectedMonth = DateTime.parse(
      data['selectedMonth'] ?? DateTime.now().toIso8601String(),
    );

    final dayNotes = data['dayNotes'] as Map<String, dynamic>? ?? {};
    dayNotes.forEach((day, note) {
      final dayInt = int.tryParse(day);
      if (dayInt != null && _dayControllers.containsKey(dayInt)) {
        _dayControllers[dayInt]!.text = note;
        _dayNotes[dayInt] = note;
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _dayControllers.values) {
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
            _buildMonthHeader(),
            _buildWeekDaysHeader(),
            Expanded(child: _buildCalendarGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left, size: 16),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _selectMonth,
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
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _nextMonth,
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

  Widget _buildWeekDaysHeader() {
    final weekDays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: widget.template.colors.first.withValues(alpha: 0.1),
                border: Border.all(color: Colors.grey[300]!, width: 0.5),
              ),
              child: Text(
                day.substring(0, 3), // Show first 3 letters
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.template.colors.first,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;

    // Convert to Sunday = 0, Monday = 1, etc.
    final firstWeekday = firstDayOfMonth.weekday % 7;

    // Calculate weeks needed
    final weeksNeeded = ((daysInMonth + firstWeekday) / 7).ceil();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available height per week
          final availableHeight = constraints.maxHeight;
          final weekHeight = (availableHeight / weeksNeeded).clamp(50.0, 70.0);

          return Column(
            children: List.generate(weeksNeeded, (weekIndex) {
              return SizedBox(
                height: weekHeight,
                child: Row(
                  children: List.generate(7, (dayIndex) {
                    final dayNumber =
                        (weekIndex * 7) + dayIndex - firstWeekday + 1;

                    if (dayNumber <= 0 || dayNumber > daysInMonth) {
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 0.5,
                            ),
                            color: Colors.grey[50],
                          ),
                        ),
                      );
                    }

                    final isToday =
                        DateTime.now().day == dayNumber &&
                        DateTime.now().month == _selectedMonth.month &&
                        DateTime.now().year == _selectedMonth.year;

                    final hasNote = _dayNotes[dayNumber]?.isNotEmpty ?? false;
                    final noteText = _dayNotes[dayNumber] ?? '';

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _showDayDialog(dayNumber),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? widget.template.colors.first.withValues(
                                    alpha: 0.2,
                                  )
                                : Colors.white,
                            border: Border.all(
                              color: isToday
                                  ? widget.template.colors.first
                                  : Colors.grey[300]!,
                              width: isToday ? 1.5 : 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date number
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? widget.template.colors.first
                                        : hasNote
                                        ? widget.template.colors.first
                                              .withValues(alpha: 0.3)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      dayNumber.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isToday
                                            ? Colors.white
                                            : hasNote
                                            ? widget.template.colors.first
                                            : Colors.black87,
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                // Note preview
                                if (hasNote && weekHeight > 55) ...[
                                  const SizedBox(height: 1),
                                  Expanded(
                                    child: Text(
                                      noteText,
                                      style: const TextStyle(
                                        fontSize: 6,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  void _showDayDialog(int day) {
    final controller = _dayControllers[day]!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${DateFormat('MMMM').format(_selectedMonth)} $day',
          style: const TextStyle(fontSize: 16),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Add your notes for this day...',
              hintStyle: TextStyle(fontSize: 12),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
              isDense: true,
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
                _dayNotes[day] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _initializeControllers();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _initializeControllers();
    });
  }

  Future<void> _selectMonth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (date != null) {
      setState(() {
        _selectedMonth = DateTime(date.year, date.month);
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
              leading: const Icon(Icons.photo_library),
              title: const Text('Save to Gallery'),
              onTap: () {
                Navigator.pop(context);
                _saveToGallery();
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

  void _saveToGallery() async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(const SnackBar(content: Text('Exporting image...')));

    final result = await GalleryExportService.saveScrollableToGallery(
      context: context,
      fileName:
          '${widget.template.name}_${DateFormat('yyyyMM').format(_selectedMonth)}',
      builder: (ctx) => _buildCaptureContent(),
      fixedHeight: 1200.0,
      pixelRatio: 3.0,
    );

    scaffold.hideCurrentSnackBar();
    if (!mounted) return;

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

  void _shareTemplate() async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Text('Preparing to share...')),
    );

    try {
      // Create a local file for sharing (not saved to gallery)
      final result = await GalleryExportService.captureToLocalFile(
        context: context,
        fileName:
            'share_${widget.template.name}_${DateTime.now().millisecondsSinceEpoch}',
        builder: (ctx) => _buildCaptureContent(),
        isScrollable: true,
        fixedHeight: 1200.0,
        pixelRatio: 3.0,
      );

      scaffold.hideCurrentSnackBar();
      if (!mounted) return;

      if (result.success && result.filePath != null) {
        await Share.shareXFiles(
          [XFile(result.filePath!)],
          text:
              'Check out my ${widget.template.name} for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
        );

        // Clean up the file after sharing
        Future.delayed(const Duration(seconds: 5), () async {
          try {
            final file = File(result.filePath!);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            // Ignore cleanup errors
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to prepare share: ${result.error}')),
        );
      }
    } catch (e) {
      scaffold.hideCurrentSnackBar();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  Future<void> _saveTemplate() async {
    // Show save dialog to get custom name
    final customName = await _showSaveDialog();
    if (customName == null) return; // User cancelled

    await _performSave(customName);
  }

  Future<String?> _showSaveDialog() async {
    final defaultName =
        '${widget.template.name} - ${DateFormat('MMMM yyyy').format(_selectedMonth)}';

    return await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SaveTemplateDialog(
              defaultName: defaultName,
              templateType: 'Monthly',
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _performSave(String customName) async {
    final data = {
      'selectedMonth': _selectedMonth.toIso8601String(),
      'dayNotes': Map.fromEntries(
        _dayNotes.entries.map((e) => MapEntry(e.key.toString(), e.value)),
      ),
    };

    try {
      final databaseHelper = DatabaseHelper();

      if (widget.existingData != null) {
        final existingTemplates = await databaseHelper.getAllSavedTemplates();
        final existingTemplate = existingTemplates.firstWhere(
          (t) =>
              t.templateId == widget.template.id &&
              t.updatedAt.month == _selectedMonth.month &&
              t.updatedAt.year == _selectedMonth.year,
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
          const SnackBar(content: Text('Monthly template saved successfully!')),
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

  Widget _buildCaptureContent() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthHeader(),
          const SizedBox(height: 8),
          _buildWeekDaysHeader(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }
}
