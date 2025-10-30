import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/saved_template_model.dart';
import '../models/notification_model.dart';

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
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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

    await db.execute('''
      CREATE TABLE notifications(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          time TEXT NOT NULL,
          description TEXT,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      // Check if notifications table exists and has the correct structure
      try {
        // Try to query the table structure
        final result = await db.rawQuery("PRAGMA table_info(notifications)");
        final columns = result.map((row) => row['name'] as String).toList();

        if (!columns.contains('created_at') ||
            !columns.contains('updated_at')) {
          await db.execute('DROP TABLE IF EXISTS notifications');
          await db.execute('''
            CREATE TABLE notifications(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              date TEXT NOT NULL,
              time TEXT NOT NULL,
              description TEXT,
              isCompleted INTEGER NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
        }
      } catch (e) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notifications(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            description TEXT,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      }
    }
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

  // Notification operations
  Future<String> insertNotification(NotificationModel notification) async {
    try {
      final db = await database;
      final map = notification.toMap();

      await db.insert(
        'notifications',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return notification.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      orderBy: 'date ASC, time ASC',
    );

    return List.generate(maps.length, (i) {
      return NotificationModel.fromMap(maps[i]);
    });
  }

  Future<List<NotificationModel>> getNotificationsForDate(DateTime date) async {
    final db = await database;
    final targetDate = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String().substring(0, 10);

    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'substr(date, 1, 10) = ?',
      whereArgs: [targetDate],
      orderBy: 'time ASC',
    );

    return List.generate(maps.length, (i) {
      return NotificationModel.fromMap(maps[i]);
    });
  }

  Future<NotificationModel?> getNotification(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return NotificationModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateNotification(NotificationModel notification) async {
    final db = await database;
    await db.update(
      'notifications',
      notification.toMap(),
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  Future<void> deleteNotification(String id) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<NotificationModel>> getPendingNotifications() async {
    final db = await database;
    final now = DateTime.now();

    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'isCompleted = ? AND datetime(date || "T" || time) >= datetime(?)',
      whereArgs: [0, now.toIso8601String()],
      orderBy: 'date ASC, time ASC',
    );

    return List.generate(maps.length, (i) {
      return NotificationModel.fromMap(maps[i]);
    });
  }

  Future<void> markNotificationAsCompleted(String id) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isCompleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
