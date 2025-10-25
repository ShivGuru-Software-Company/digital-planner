import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../models/entry_model.dart';
import '../models/template_model.dart';
import '../providers/planner_provider.dart';
import '../services/notification_service.dart';
import 'drawing_screen.dart';

class EntryEditorScreen extends StatefulWidget {
  final EntryModel? entry;
  final TemplateModel? template;
  final DateTime? selectedDate;

  const EntryEditorScreen({
    super.key,
    this.entry,
    this.template,
    this.selectedDate,
  });

  @override
  State<EntryEditorScreen> createState() => _EntryEditorScreenState();
}

class _EntryEditorScreenState extends State<EntryEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  String? _drawingData;
  List<String> _images = [];
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
    _selectedDate = widget.entry?.date ?? widget.selectedDate ?? DateTime.now();
    _drawingData = widget.entry?.drawingData;
    _images = widget.entry?.images ?? [];

    // Initialize reminder time from existing entry
    if (widget.entry?.reminderTime != null &&
        widget.entry!.reminderTime!.isNotEmpty) {
      final timeParts = widget.entry!.reminderTime!.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null && minute != null) {
          _reminderTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
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
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveEntry),
          if (widget.entry != null)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteEntry),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSelector(),
            const SizedBox(height: 20),
            _buildTitleField(),
            const SizedBox(height: 20),
            _buildContentField(),
            const SizedBox(height: 20),
            _buildToolbar(),
            const SizedBox(height: 20),
            if (_images.isNotEmpty) _buildImagesSection(),
            if (_drawingData != null) _buildDrawingPreview(),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
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

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Enter title',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      maxLines: 10,
      decoration: InputDecoration(
        labelText: 'Content',
        hintText: 'Write your thoughts...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildToolbar() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildToolButton(icon: Icons.brush, label: 'Draw', onTap: _openDrawing),
        _buildToolButton(icon: Icons.image, label: 'Image', onTap: _pickImage),
        _buildReminderButton(),
        _buildToolButton(icon: Icons.format_bold, label: 'Bold', onTap: () {}),
        _buildToolButton(
          icon: Icons.format_italic,
          label: 'Italic',
          onTap: () {},
        ),
      ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6366F1)),
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
              ? const Color(0xFF6366F1).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasReminder
                ? const Color(0xFF6366F1)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasReminder ? Icons.notifications_active : Icons.notifications,
              size: 20,
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(width: 8),
            Text(
              reminderText,
              style: TextStyle(
                color: hasReminder
                    ? const Color(0xFF6366F1)
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
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
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
    );
  }

  Widget _buildDrawingPreview() {
    return Column(
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

    final entry = EntryModel(
      id: widget.entry?.id ?? const Uuid().v4(),
      templateId: widget.template?.id ?? widget.entry?.templateId ?? 'default',
      date: _selectedDate,
      title: _titleController.text,
      content: _contentController.text,
      drawingData: _drawingData,
      images: _images,
      createdAt: widget.entry?.createdAt ?? now,
      updatedAt: now,
      reminderTime: _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : widget.entry?.reminderTime,
    );

    if (widget.entry == null) {
      await provider.addEntry(entry);
    } else {
      await provider.updateEntry(entry);
    }

    if (mounted) {
      Navigator.pop(context);
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

    if (confirmed == true && widget.entry != null) {
      final provider = Provider.of<PlannerProvider>(context, listen: false);
      await provider.deleteEntry(widget.entry!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
