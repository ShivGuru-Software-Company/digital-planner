import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/template_model.dart';
import '../models/entry_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('planner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE templates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        colors TEXT NOT NULL,
        customData TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE entries (
        id TEXT PRIMARY KEY,
        templateId TEXT NOT NULL,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        drawingData TEXT,
        images TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        reminderTime TEXT,
        FOREIGN KEY (templateId) REFERENCES templates (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_entries_date ON entries(date)
    ''');

    await db.execute('''
      CREATE INDEX idx_entries_template ON entries(templateId)
    ''');
  }

  Future<int> insertTemplate(TemplateModel template) async {
    final db = await database;
    return await db.insert('templates', template.toMap());
  }

  Future<List<TemplateModel>> getAllTemplates() async {
    final db = await database;
    final result = await db.query('templates');
    return result.map((map) => TemplateModel.fromMap(map)).toList();
  }

  Future<TemplateModel?> getTemplate(String id) async {
    final db = await database;
    final result = await db.query(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return TemplateModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateTemplate(TemplateModel template) async {
    final db = await database;
    return await db.update(
      'templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<int> deleteTemplate(String id) async {
    final db = await database;
    return await db.delete(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertEntry(EntryModel entry) async {
    final db = await database;
    return await db.insert('entries', entry.toMap());
  }

  Future<List<EntryModel>> getAllEntries() async {
    final db = await database;
    final result = await db.query('entries', orderBy: 'date DESC');
    return result.map((map) => EntryModel.fromMap(map)).toList();
  }

  Future<EntryModel?> getEntry(String id) async {
    final db = await database;
    final result = await db.query(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return EntryModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<EntryModel>> getEntriesForDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    final result = await db.query(
      'entries',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => EntryModel.fromMap(map)).toList();
  }

  Future<List<EntryModel>> getEntriesForTemplate(String templateId) async {
    final db = await database;
    final result = await db.query(
      'entries',
      where: 'templateId = ?',
      whereArgs: [templateId],
      orderBy: 'date DESC',
    );
    return result.map((map) => EntryModel.fromMap(map)).toList();
  }

  Future<int> updateEntry(EntryModel entry) async {
    final db = await database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(String id) async {
    final db = await database;
    return await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
