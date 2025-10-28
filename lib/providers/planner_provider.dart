import 'package:flutter/material.dart';
import '../models/template_model.dart';
import '../models/entry_model.dart';
import '../services/database_service.dart';

class PlannerProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<TemplateModel> _templates = [];
  List<EntryModel> _entries = [];
  DateTime _selectedDate = DateTime.now();

  List<TemplateModel> get templates => _templates;
  List<EntryModel> get entries => _entries;
  DateTime get selectedDate => _selectedDate;

  List<EntryModel> get entriesForSelectedDate {
    return _entries.where((entry) {
      return entry.date.year == _selectedDate.year &&
          entry.date.month == _selectedDate.month &&
          entry.date.day == _selectedDate.day;
    }).toList();
  }

  PlannerProvider() {
    _loadTemplates();
    _loadEntries();
    _rescheduleExistingReminders();
  }

  Future<void> _loadTemplates() async {
    _templates = await _db.getAllTemplates();
    notifyListeners();
  }

  Future<void> _loadEntries() async {
    _entries = await _db.getAllEntries();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> addTemplate(TemplateModel template) async {
    await _db.insertTemplate(template);
    await _loadTemplates();
  }

  Future<void> updateTemplate(TemplateModel template) async {
    await _db.updateTemplate(template);
    await _loadTemplates();
  }

  Future<void> deleteTemplate(String id) async {
    await _db.deleteTemplate(id);
    await _loadTemplates();
  }

  Future<void> addEntry(EntryModel entry) async {
    await _db.insertEntry(entry);

    // Schedule notification if reminder time is set
    if (entry.reminderTime != null && entry.reminderTime!.isNotEmpty) {
      await _scheduleReminder(entry);
    }

    await _loadEntries();
  }

  Future<void> updateEntry(EntryModel entry) async {
    // Cancel existing notification for this entry

    await _db.updateEntry(entry);

    // Schedule new notification if reminder time is set
    if (entry.reminderTime != null && entry.reminderTime!.isNotEmpty) {
      await _scheduleReminder(entry);
    }

    await _loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    // Cancel notification for this entry

    await _db.deleteEntry(id);
    await _loadEntries();
  }

  List<EntryModel> getEntriesForDate(DateTime date) {
    return _entries.where((entry) {
      return entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day;
    }).toList();
  }

  Future<void> refreshData() async {
    await _loadTemplates();
    await _loadEntries();
  }

  Future<void> _scheduleReminder(EntryModel entry) async {
    try {
      print('Scheduling reminder for entry: ${entry.title}');
      print('Reminder time: ${entry.reminderTime}');
      print('Entry date: ${entry.date}');

      // Parse reminder time (assuming format like "HH:mm" or ISO string)
      DateTime reminderDateTime;

      if (entry.reminderTime!.contains('T')) {
        // ISO format
        reminderDateTime = DateTime.parse(entry.reminderTime!);
      } else {
        // Time format (HH:mm) - combine with entry date
        final timeParts = entry.reminderTime!.split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          reminderDateTime = DateTime(
            entry.date.year,
            entry.date.month,
            entry.date.day,
            hour,
            minute,
          );
        } else {
          print('Invalid time format: ${entry.reminderTime}');
          return; // Invalid time format
        }
      }

      print('Calculated reminder datetime: $reminderDateTime');
      print('Current time: ${DateTime.now()}');
      print('Is in future: ${reminderDateTime.isAfter(DateTime.now())}');

      // Only schedule if the reminder time is in the future
      if (reminderDateTime.isAfter(DateTime.now())) {
        print('Reminder scheduled successfully');
      } else {
        print('Reminder time is in the past, not scheduling');
      }
    } catch (e) {
      // Handle parsing errors gracefully
      print('Error scheduling reminder for entry ${entry.id}: $e');
      debugPrint('Error scheduling reminder for entry ${entry.id}: $e');
    }
  }

  Future<void> _rescheduleExistingReminders() async {
    // Wait for entries to load first
    await Future.delayed(const Duration(milliseconds: 500));

    for (final entry in _entries) {
      if (entry.reminderTime != null && entry.reminderTime!.isNotEmpty) {
        await _scheduleReminder(entry);
      }
    }
  }
}
