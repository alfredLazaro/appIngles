import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "DataBaseHelper.dart";
import "../../models/progress_model.dart";

class ProgressDao {
  final dbHelper = DatabaseService();

  Future<Map<int, int>> getAllLearnCounts() async {
    try {
      final db = await dbHelper.database;
      final rows = await db.rawQuery('SELECT word_id, learn, word FROM progress');
      return {for (final r in rows) r['word_id'] as int: (r['learn'] as int?) ?? 0};
    } catch (e) {
      debugPrint('❌ ProgressDao.getAllLearnCounts error: $e');
      return {};
    }
  }

  Future<void> upsertInTransaction(Database txn, int word_id, int learn, String word, String now) async {
    await txn.insert(
      'progress',
      {
        'word_id': word_id,
        'word': word,
        'learn': learn,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsert(int word_id, int learn, String word, String now) async {
    try {
      final db = await dbHelper.database;
      await db.insert(
        'progress',
        {'word_id': word_id, 'learn': learn, 'word': word, 'updated_at': now},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ ProgressDao.upsert error: $e');
      rethrow;
    }
  }

  Future<int?> getLearnByword_id(int word_id) async {
    try {
      final db = await dbHelper.database;
      final rows = await db.query(
        'progress',
        columns: ['learn'],
        where: 'word_id = ?',
        whereArgs: [word_id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first['learn'] as int?;
    } catch (e) {
      debugPrint('❌ ProgressDao.getLearnByword_id error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final db = await dbHelper.database;
      return await db.query('progress');
    } catch (e) {
      debugPrint('❌ ProgressDao.getAll error: $e');
      return [];
    }
  }

  Future<void> updateFromServer(int word_id, int learn, String word, String updatedAt, String syncedAt) async {
    try {
      final db = await dbHelper.database;
      await db.insert(
        'progress',
        {
          'word_id': word_id,
          'word': word,
          'learn': learn,
          'updated_at': updatedAt,
          'synced_at': syncedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ ProgressDao.updateFromServer error: $e');
      rethrow;
    }
  }

  Future<List<ProgressModel>> getWithLearnGreaterThanZero() async {
    try {
      final db = await dbHelper.database;
      final rows = await db.query('progress', where: 'learn > 0');
      return rows.map(ProgressModel.fromMap).toList();
    } catch (e) {
      debugPrint('❌ ProgressDao.getWithLearnGreaterThanZero error: $e');
      return [];
    }
  }

  Future<Set<DateTime>> getPracticeDates() async {
    try {
      final db = await dbHelper.database;
      final rows = await db.rawQuery(
          "SELECT DISTINCT date(updated_at) AS d FROM progress WHERE updated_at IS NOT NULL");
      return rows.map((r) {
        final parts = (r['d'] as String).split('-');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }).toSet();
    } catch (e) {
      debugPrint('❌ ProgressDao.getPracticeDates error: $e');
      return {};
    }
  }

  Future<bool> exists(int word_id) async {
    try {
      final db = await dbHelper.database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM progress WHERE word_id = ?', [word_id]),
      );
      return (count ?? 0) > 0;
    } catch (e) {
      debugPrint('❌ ProgressDao.exists error: $e');
      return false;
    }
  }
}