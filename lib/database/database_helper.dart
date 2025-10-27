import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/saved_template_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'planner_templates.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saved_templates(
        id TEXT PRIMARY KEY,
        template_id TEXT NOT NULL,
        template_name TEXT NOT NULL,
        template_type TEXT NOT NULL,
        template_design TEXT NOT NULL,
        template_colors TEXT NOT NULL,
        template_icon INTEGER NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<String> insertSavedTemplate(SavedTemplateModel template) async {
    final db = await database;
    await db.insert(
      'saved_templates',
      template.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return template.id;
  }

  Future<List<SavedTemplateModel>> getAllSavedTemplates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_templates',
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SavedTemplateModel.fromMap(maps[i]);
    });
  }

  Future<SavedTemplateModel?> getSavedTemplate(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_templates',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SavedTemplateModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateSavedTemplate(SavedTemplateModel template) async {
    final db = await database;
    await db.update(
      'saved_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<void> deleteSavedTemplate(String id) async {
    final db = await database;
    await db.delete('saved_templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SavedTemplateModel>> getSavedTemplatesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'saved_templates',
      where: 'template_type = ?',
      whereArgs: [type],
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return SavedTemplateModel.fromMap(maps[i]);
    });
  }
}
