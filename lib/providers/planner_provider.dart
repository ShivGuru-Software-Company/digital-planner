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
    await _loadEntries();
  }

  Future<void> updateEntry(EntryModel entry) async {
    await _db.updateEntry(entry);
    await _loadEntries();
  }

  Future<void> deleteEntry(String id) async {
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
}
