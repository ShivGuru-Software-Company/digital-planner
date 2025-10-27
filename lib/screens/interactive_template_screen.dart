import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/template_model.dart';
import '../models/entry_model.dart';
import '../providers/planner_provider.dart';
import '../widgets/glass_card.dart';
import 'drawing_screen.dart';

class InteractiveTemplateScreen extends StatefulWidget {
  final TemplateModel template;
  final EntryModel? existingEntry;

  const InteractiveTemplateScreen({
    super.key,
    required this.template,
    this.existingEntry,
  });

  @override
  State<InteractiveTemplateScreen> createState() =>
      _InteractiveTemplateScreenState();
}

class _InteractiveTemplateScreenState extends State<InteractiveTemplateScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  String? _drawingData;
  List<String> _images = [];
  TimeOfDay? _reminderTime;
  Map<String, dynamic> _templateData = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingEntry?.title ?? widget.template.name,
    );
    _contentController = TextEditingController(
      text: widget.existingEntry?.content ?? '',
    );
    _selectedDate = widget.existingEntry?.date ?? DateTime.now();
    _drawingData = widget.existingEntry?.drawingData;
    _images = widget.existingEntry?.images ?? [];

    // Initialize reminder time from existing entry
    if (widget.existingEntry?.reminderTime != null &&
        widget.existingEntry!.reminderTime!.isNotEmpty) {
      final timeParts = widget.existingEntry!.reminderTime!.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          _reminderTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }

    _initializeTemplateData();
  }

  void _initializeTemplateData() {
    // Initialize template-specific data based on template type
    switch (widget.template.category.toLowerCase()) {
      case 'daily':
        _templateData = {
          'mood': 5,
          'energy': 5,
          'productivity': 5,
          'gratitude': ['', '', ''],
          'goals': ['', '', ''],
          'habits': <String, bool>{},
        };
        break;
      case 'weekly':
        _templateData = {
          'weeklyGoals': ['', '', '', '', ''],
          'achievements': ['', '', ''],
          'challenges': '',
          'nextWeekFocus': '',
        };
        break;
      case 'monthly':
        _templateData = {
          'monthlyGoals': ['', '', '', '', '', ''],
          'keyAchievements': ['', '', '', ''],
          'lessonsLearned': '',
          'nextMonthPriorities': ['', '', ''],
        };
        break;
      case 'fitness':
        _templateData = {
          'workoutType': '',
          'duration': 0,
          'exercises': <Map<String, dynamic>>[],
          'caloriesBurned': 0,
          'notes': '',
        };
        break;
      case 'finance':
        _templateData = {
          'income': 0.0,
          'expenses': <Map<String, dynamic>>[],
          'savings': 0.0,
          'budget': <String, double>{},
          'financialGoals': ['', '', ''],
        };
        break;
      default:
        _templateData = {};
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
          IconButton(icon: const Icon(Icons.check), onPressed: _saveEntry),
          if (widget.existingEntry != null)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteEntry),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 20),
                _buildBasicInfoSection(),
                const SizedBox(height: 20),
                _buildTemplateSpecificSection(),
                const SizedBox(height: 20),
                _buildToolsSection(),
                const SizedBox(height: 20),
                if (_images.isNotEmpty) _buildImagesSection(),
                if (_drawingData != null) _buildDrawingPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.template.colors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.template.icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.template.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.template.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Add your thoughts and notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: widget.template.colors),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSpecificSection() {
    switch (widget.template.category.toLowerCase()) {
      case 'daily':
        return _buildDailyTemplate();
      case 'weekly':
        return _buildWeeklyTemplate();
      case 'monthly':
        return _buildMonthlyTemplate();
      case 'fitness':
        return _buildFitnessTemplate();
      case 'finance':
        return _buildFinanceTemplate();
      default:
        return _buildGenericTemplate();
    }
  }

  Widget _buildDailyTemplate() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Reflection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildSliderSection('Mood', 'mood', 1, 10),
            _buildSliderSection('Energy Level', 'energy', 1, 10),
            _buildSliderSection('Productivity', 'productivity', 1, 10),
            const SizedBox(height: 16),
            _buildGratitudeSection(),
            const SizedBox(height: 16),
            _buildGoalsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTemplate() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildListSection('Weekly Goals', 'weeklyGoals', 5),
            const SizedBox(height: 16),
            _buildListSection('Key Achievements', 'achievements', 3),
            const SizedBox(height: 16),
            _buildTextFieldSection('Challenges Faced', 'challenges'),
            const SizedBox(height: 16),
            _buildTextFieldSection('Next Week Focus', 'nextWeekFocus'),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTemplate() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildListSection('Monthly Goals', 'monthlyGoals', 6),
            const SizedBox(height: 16),
            _buildListSection('Key Achievements', 'keyAchievements', 4),
            const SizedBox(height: 16),
            _buildTextFieldSection('Lessons Learned', 'lessonsLearned'),
            const SizedBox(height: 16),
            _buildListSection(
              'Next Month Priorities',
              'nextMonthPriorities',
              3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessTemplate() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fitness Tracker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildTextFieldSection('Workout Type', 'workoutType'),
            const SizedBox(height: 16),
            _buildNumberFieldSection('Duration (minutes)', 'duration'),
            const SizedBox(height: 16),
            _buildNumberFieldSection('Calories Burned', 'caloriesBurned'),
            const SizedBox(height: 16),
            _buildTextFieldSection('Workout Notes', 'notes'),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceTemplate() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Finance Tracker',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildNumberFieldSection('Income', 'income', isDouble: true),
            const SizedBox(height: 16),
            _buildNumberFieldSection('Savings', 'savings', isDouble: true),
            const SizedBox(height: 16),
            _buildListSection('Financial Goals', 'financialGoals', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericTemplate() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.template.category} Template',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use the notes section above to add your content for this template.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSection(String label, String key, int min, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${_templateData[key]?.toInt() ?? min}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Slider(
          value: (_templateData[key] ?? min).toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (value) {
            setState(() {
              _templateData[key] = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildGratitudeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Three Things I\'m Grateful For:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              onChanged: (value) {
                final gratitude = List<String>.from(
                  _templateData['gratitude'] ?? ['', '', ''],
                );
                gratitude[index] = value;
                _templateData['gratitude'] = gratitude;
              },
              decoration: InputDecoration(
                hintText: '${index + 1}. What are you grateful for?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Goals:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              onChanged: (value) {
                final goals = List<String>.from(
                  _templateData['goals'] ?? ['', '', ''],
                );
                goals[index] = value;
                _templateData['goals'] = goals;
              },
              decoration: InputDecoration(
                hintText: '${index + 1}. Goal for today',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildListSection(String title, String key, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ...List.generate(count, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              onChanged: (value) {
                final list = List<String>.from(
                  _templateData[key] ?? List.filled(count, ''),
                );
                list[index] = value;
                _templateData[key] = list;
              },
              decoration: InputDecoration(
                hintText: '${index + 1}. Enter item',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextFieldSection(String title, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          onChanged: (value) {
            _templateData[key] = value;
          },
          decoration: InputDecoration(
            hintText: 'Enter your thoughts...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberFieldSection(
    String title,
    String key, {
    bool isDouble = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (isDouble) {
              _templateData[key] = double.tryParse(value) ?? 0.0;
            } else {
              _templateData[key] = int.tryParse(value) ?? 0;
            }
          },
          decoration: InputDecoration(
            hintText: 'Enter ${isDouble ? 'amount' : 'number'}',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildToolsSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildToolButton(
                  icon: Icons.brush,
                  label: 'Draw',
                  onTap: _openDrawing,
                ),
                _buildToolButton(
                  icon: Icons.image,
                  label: 'Image',
                  onTap: _pickImage,
                ),
                _buildReminderButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: widget.template.colors.first),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderButton() {
    final hasReminder = _reminderTime != null;
    final reminderText = hasReminder
        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
        : 'Reminder';

    return InkWell(
      onTap: _setReminder,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasReminder
              ? widget.template.colors.first.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasReminder
                ? widget.template.colors.first
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasReminder ? Icons.notifications_active : Icons.notifications,
              size: 20,
              color: widget.template.colors.first,
            ),
            const SizedBox(width: 8),
            Text(
              reminderText,
              style: TextStyle(
                color: hasReminder
                    ? widget.template.colors.first
                    : const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasReminder) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _reminderTime = null;
                  });
                },
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: widget.template.colors.first,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Images',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: Stack(
                      children: [
                        const Center(child: Icon(Icons.image, size: 40)),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _images.removeAt(index);
                              });
                            },
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
  }

  Widget _buildDrawingPreview() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Drawing',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _drawingData = null;
                    });
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
              child: const Center(child: Icon(Icons.brush, size: 60)),
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

  Future<void> _openDrawing() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DrawingScreen(drawingData: _drawingData),
      ),
    );

    if (result != null) {
      setState(() {
        _drawingData = result;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _images.add(image.path);
      });
    }
  }

  Future<void> _setReminder() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _reminderTime = time;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder set successfully')),
        );
      }
    }
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    final provider = Provider.of<PlannerProvider>(context, listen: false);
    final now = DateTime.now();

    // Combine content with template data
    String combinedContent = _contentController.text;
    if (_templateData.isNotEmpty) {
      combinedContent += '\n\n--- Template Data ---\n';
      _templateData.forEach((key, value) {
        combinedContent += '$key: $value\n';
      });
    }

    final entry = EntryModel(
      id: widget.existingEntry?.id ?? const Uuid().v4(),
      templateId: widget.template.id,
      date: _selectedDate,
      title: _titleController.text,
      content: combinedContent,
      drawingData: _drawingData,
      images: _images,
      createdAt: widget.existingEntry?.createdAt ?? now,
      updatedAt: now,
      reminderTime: _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : widget.existingEntry?.reminderTime,
    );

    try {
      if (widget.existingEntry == null) {
        await provider.addEntry(entry);
      } else {
        await provider.updateEntry(entry);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving entry: $e')));
      }
    }
  }

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.existingEntry != null) {
      final provider = Provider.of<PlannerProvider>(context, listen: false);
      try {
        await provider.deleteEntry(widget.existingEntry!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting entry: $e')));
        }
      }
    }
  }
}
