import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    _database = await openDatabase(
      p.join(root, 'mediakit.db'),
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE projects (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          projectType TEXT NOT NULL,
          coverImagePath TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )''');
        await db.execute('''CREATE TABLE resources (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          projectId INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
          name TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          category TEXT NOT NULL,
          originalFileName TEXT NOT NULL,
          fileExtension TEXT NOT NULL,
          localFilePath TEXT NOT NULL,
          fileSize INTEGER NOT NULL,
          imageWidth INTEGER,
          imageHeight INTEGER,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )''');
      },
    );
    return _database!;
  }
}
