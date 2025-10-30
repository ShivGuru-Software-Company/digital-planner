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

class MoodTemplateScreen extends StatefulWidget {
  final PlannerTemplate template;
  final TemplateData? existingData;

  const MoodTemplateScreen({
    super.key,
    required this.template,
    this.existingData,
  });

  @override
  State<MoodTemplateScreen> createState() => _MoodTemplateScreenState();
}

class _MoodTemplateScreenState extends State<MoodTemplateScreen> {
  late DateTime _selectedDate;

  // Mood tracking
  String _selectedMood = '';
  int _moodIntensity = 5;
  int _energyLevel = 5;
  int _stressLevel = 5;
  int _sleepQuality = 5;

  // Text controllers
  final TextEditingController _thoughtsController = TextEditingController();
  final TextEditingController _gratitudeController = TextEditingController();
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();

  // Activities and triggers
  final List<String> _selectedActivities = [];
  final List<String> _selectedTriggers = [];

  // Mood options with emojis
  final Map<String, MoodOption> _moodOptions = {
    'Excellent': MoodOption('😄', 'Excellent', Colors.green),
    'Good': MoodOption('😊', 'Good', Colors.lightGreen),
    'Okay': MoodOption('😐', 'Okay', Colors.orange),
    'Bad': MoodOption('😔', 'Bad', Colors.red),
    'Terrible': MoodOption('😢', 'Terrible', Colors.deepOrange),
    'Anxious': MoodOption('😰', 'Anxious', Colors.purple),
    'Excited': MoodOption('🤩', 'Excited', Colors.pink),
    'Calm': MoodOption('😌', 'Calm', Colors.blue),
  };

  // Activities list
  final List<String> _activities = [
    'Exercise',
    'Reading',
    'Music',
    'Friends',
    'Family',
    'Work',
    'Meditation',
    'Nature',
    'Cooking',
    'Gaming',
    'Art',
    'Learning',
  ];

  // Mood triggers
  final List<String> _triggers = [
    'Work Stress',
    'Relationships',
    'Health',
    'Money',
    'Weather',
    'Sleep',
    'Social Media',
    'News',
    'Traffic',
    'Deadlines',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    if (widget.existingData != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final data = widget.existingData!.data;
    _selectedDate = DateTime.parse(
      data['selectedDate'] ?? DateTime.now().toIso8601String(),
    );
    _selectedMood = data['selectedMood'] ?? '';
    _moodIntensity = data['moodIntensity'] ?? 5;
    _energyLevel = data['energyLevel'] ?? 5;
    _stressLevel = data['stressLevel'] ?? 5;
    _sleepQuality = data['sleepQuality'] ?? 5;

    _thoughtsController.text = data['thoughts'] ?? '';
    _gratitudeController.text = data['gratitude'] ?? '';
    _goalsController.text = data['goals'] ?? '';
    _reflectionController.text = data['reflection'] ?? '';

    _selectedActivities.addAll(List<String>.from(data['activities'] ?? []));
    _selectedTriggers.addAll(List<String>.from(data['triggers'] ?? []));
  }

  @override
  void dispose() {
    _thoughtsController.dispose();
    _gratitudeController.dispose();
    _goalsController.dispose();
    _reflectionController.dispose();
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
        child: _buildMoodContent(),
      ),
    );
  }

  Widget _buildMoodContent({bool capture = false}) {
    final inner = Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _buildDateSection(),
          const SizedBox(height: 8),
          _buildMoodSelector(),
          const SizedBox(height: 8),
          _buildMoodMetrics(),
          const SizedBox(height: 8),
          _buildActivitiesSection(),
          const SizedBox(height: 8),
          _buildTriggersSection(),
          const SizedBox(height: 8),
          _buildJournalSection(),
          const SizedBox(height: 8),
          _buildWellnessInsights(),
        ],
      ),
    );

    if (capture) {
      return inner; // no scroll wrapper; let it expand to full height for capture
    }
    return SingleChildScrollView(child: inner);
  }

  Widget _buildDateSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: widget.template.colors.first,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Mood Tracker',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
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

  Widget _buildMoodSelector() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moodOptions.entries.map((entry) {
                final moodKey = entry.key;
                final mood = entry.value;
                final isSelected = _selectedMood == moodKey;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = isSelected ? '' : moodKey;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? mood.color.withValues(alpha: 0.2)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected ? mood.color : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? mood.color : Colors.black87,
                          ),
                        ),
                      ],
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

  Widget _buildMoodMetrics() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Metrics',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSliderMetric(
              'Mood Intensity',
              _moodIntensity,
              Icons.sentiment_satisfied_alt,
              Colors.pink,
              (value) => setState(() => _moodIntensity = value),
            ),
            _buildSliderMetric(
              'Energy Level',
              _energyLevel,
              Icons.battery_charging_full,
              Colors.green,
              (value) => setState(() => _energyLevel = value),
            ),
            _buildSliderMetric(
              'Stress Level',
              _stressLevel,
              Icons.warning,
              Colors.orange,
              (value) => setState(() => _stressLevel = value),
            ),
            _buildSliderMetric(
              'Sleep Quality',
              _sleepQuality,
              Icons.bedtime,
              Colors.blue,
              (value) => setState(() => _sleepQuality = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderMetric(
    String label,
    int value,
    IconData icon,
    Color color,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                '$label: $value/10',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: color,
            onChanged: (newValue) => onChanged(newValue.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activities Today',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _activities.map((activity) {
                final isSelected = _selectedActivities.contains(activity);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedActivities.remove(activity);
                      } else {
                        _selectedActivities.add(activity);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.template.colors.first.withValues(alpha: 0.2)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? widget.template.colors.first
                            : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      activity,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? widget.template.colors.first
                            : Colors.black87,
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

  Widget _buildTriggersSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Triggers',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _triggers.map((trigger) {
                final isSelected = _selectedTriggers.contains(trigger);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTriggers.remove(trigger);
                      } else {
                        _selectedTriggers.add(trigger);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      trigger,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? Colors.red : Colors.black87,
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

  Widget _buildJournalSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journal & Reflection',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildJournalField(
              'Thoughts & Feelings',
              _thoughtsController,
              'How are you feeling? What\'s on your mind?',
              Icons.psychology,
            ),
            const SizedBox(height: 8),
            _buildJournalField(
              'Gratitude',
              _gratitudeController,
              'What are you grateful for today?',
              Icons.favorite,
            ),
            const SizedBox(height: 8),
            _buildJournalField(
              'Goals & Intentions',
              _goalsController,
              'What do you want to achieve today?',
              Icons.flag,
            ),
            const SizedBox(height: 8),
            _buildJournalField(
              'Evening Reflection',
              _reflectionController,
              'How was your day? What did you learn?',
              Icons.lightbulb,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalField(
    String title,
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: widget.template.colors.first),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(8),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildWellnessInsights() {
    final averageMood =
        (_moodIntensity + _energyLevel + (10 - _stressLevel) + _sleepQuality) /
        4;
    final wellnessScore = (averageMood * 10).toInt();

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wellness Insights',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    'Wellness Score',
                    '$wellnessScore%',
                    Icons.health_and_safety,
                    _getWellnessColor(wellnessScore),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInsightCard(
                    'Activities',
                    '${_selectedActivities.length}',
                    Icons.local_activity,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedMood.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _moodOptions[_selectedMood]!.color.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _moodOptions[_selectedMood]!.color.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _moodOptions[_selectedMood]!.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      'Today you\'re feeling ${_selectedMood.toLowerCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_selectedActivities.isNotEmpty)
                      Text(
                        'Activities: ${_selectedActivities.join(', ')}',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getWellnessColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
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
              leading: const Icon(Icons.photo_library),
              title: const Text('Save to Gallery'),
              onTap: () {
                Navigator.pop(context);
                _saveToGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Mood Report'),
              onTap: () {
                Navigator.pop(context);
                _shareMoodReport();
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

    final title =
        '${widget.template.name} - ${DateFormat('yyyyMMdd').format(_selectedDate)}';

    final result = await GalleryExportService.saveScrollableToGallery(
      context: context,
      fileName: title,
      fixedHeight: 1200.0, // Increased height to capture all content
      builder: (ctx) => Container(
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
        child: _buildMoodContent(capture: true),
      ),
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

  void _shareMoodReport() async {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      const SnackBar(content: Text('Preparing to share...')),
    );

    try {
      final title =
          '${widget.template.name} - ${DateFormat('yyyyMMdd').format(_selectedDate)}';

      // Create a local file for sharing (not saved to gallery)
      final result = await GalleryExportService.captureToLocalFile(
        context: context,
        fileName: 'share_$title',
        fixedHeight: 1200.0,
        isScrollable: true,
        builder: (ctx) => Container(
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
          child: _buildMoodContent(capture: true),
        ),
        pixelRatio: 3.0,
      );

      scaffold.hideCurrentSnackBar();
      if (!mounted) return;

      if (result.success && result.filePath != null) {
        await Share.shareXFiles(
          [XFile(result.filePath!)],
          text:
              'Check out my mood tracker for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
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
        '${widget.template.name} - ${DateFormat('MMM dd').format(_selectedDate)}';

    return await Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            SaveTemplateDialog(defaultName: defaultName, templateType: 'Mood'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _performSave(String customName) async {
    final data = {
      'selectedDate': _selectedDate.toIso8601String(),
      'selectedMood': _selectedMood,
      'moodIntensity': _moodIntensity,
      'energyLevel': _energyLevel,
      'stressLevel': _stressLevel,
      'sleepQuality': _sleepQuality,
      'thoughts': _thoughtsController.text,
      'gratitude': _gratitudeController.text,
      'goals': _goalsController.text,
      'reflection': _reflectionController.text,
      'activities': _selectedActivities,
      'triggers': _selectedTriggers,
    };

    try {
      final databaseHelper = DatabaseHelper();

      if (widget.existingData != null) {
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

// Data model for mood options
class MoodOption {
  final String emoji;
  final String label;
  final Color color;

  MoodOption(this.emoji, this.label, this.color);
}
