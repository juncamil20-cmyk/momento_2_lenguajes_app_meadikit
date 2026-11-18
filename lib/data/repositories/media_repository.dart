import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/media_project.dart';
import '../models/media_resource.dart';

class MediaRepository {
  MediaRepository._();
  static final MediaRepository instance = MediaRepository._();
  final AppDatabase _store = AppDatabase.instance;

  Future<List<MediaProject>> projects() async {
    final db = await _store.database;
    final rows = await db.query('projects', orderBy: 'updatedAt DESC');
    return rows.map(MediaProject.fromMap).toList();
  }

  Future<MediaProject?> project(int id) async {
    final db = await _store.database;
    final rows = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : MediaProject.fromMap(rows.first);
  }

  Future<int> saveProject(MediaProject project) async {
    final db = await _store.database;
    return db.insert(
      'projects',
      project.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateProject(MediaProject project) async {
    final db = await _store.database;
    await db.update(
      'projects',
      project.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<void> deleteProject(int id) async {
    final db = await _store.database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MediaResource>> resources({
    int? projectId,
    String? category,
  }) async {
    final db = await _store.database;
    final where = <String>[];
    final args = <Object?>[];
    if (projectId != null) {
      where.add('projectId = ?');
      args.add(projectId);
    }
    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }
    final rows = await db.query(
      'resources',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'createdAt DESC',
    );
    return rows.map(MediaResource.fromMap).toList();
  }

  Future<MediaResource?> resource(int id) async {
    final db = await _store.database;
    final rows = await db.query(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : MediaResource.fromMap(rows.first);
  }

  Future<int> saveResource(MediaResource resource) async {
    final db = await _store.database;
    final id = await db.insert(
      'resources',
      resource.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    await _touchProject(db, resource.projectId);
    return id;
  }

  Future<void> updateResource(MediaResource resource) async {
    final db = await _store.database;
    await db.update(
      'resources',
      resource.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
    await _touchProject(db, resource.projectId);
  }

  Future<void> deleteResource(int id) async {
    final db = await _store.database;
    final rows = await db.query(
      'resources',
      columns: ['projectId'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    await db.delete('resources', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      await _touchProject(db, rows.first['projectId'] as int);
    }
  }

  Future<void> _touchProject(Database db, int projectId) async {
    await db.update(
      'projects',
      {'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<Map<int, int>> resourceCounts() async {
    final db = await _store.database;
    final rows = await db.rawQuery(
      'SELECT projectId, COUNT(*) AS total FROM resources GROUP BY projectId',
    );
    return {
      for (final row in rows) row['projectId'] as int: row['total'] as int,
    };
  }
}
