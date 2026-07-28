import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "DataBaseHelper.dart";

class ProgressDao {
  final dbHelper = DatabaseService();

  Future<Map<int, int>> getAllLearnCounts() async {
    try {
      final db = await dbHelper.database;
      final rows = await db.rawQuery('SELECT word_id, learn FROM progress');
      return {for (final r in rows) r['word_id'] as int: (r['learn'] as int?) ?? 0};
    } catch (e) {
      debugPrint('❌ ProgressDao.getAllLearnCounts error: $e');
      return {};
    }
  }

  Future<void> upsertInTransaction(Database txn, int wordId, int learn, String now) async {
    await txn.insert(
      'progress',
      {
        'word_id': wordId,
        'learn': learn,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsert(int wordId, int learn, String now) async {
    try {
      final db = await dbHelper.database;
      await db.insert(
        'progress',
        {'word_id': wordId, 'learn': learn, 'updated_at': now},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('❌ ProgressDao.upsert error: $e');
      rethrow;
    }
  }

  Future<int?> getLearnByWordId(int wordId) async {
    try {
      final db = await dbHelper.database;
      final rows = await db.query(
        'progress',
        columns: ['learn'],
        where: 'word_id = ?',
        whereArgs: [wordId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first['learn'] as int?;
    } catch (e) {
      debugPrint('❌ ProgressDao.getLearnByWordId error: $e');
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

  Future<void> updateFromServer(int wordId, int learn, String updatedAt, String syncedAt) async {
    try {
      final db = await dbHelper.database;
      await db.insert(
        'progress',
        {
          'word_id': wordId,
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

  Future<bool> exists(int wordId) async {
    try {
      final db = await dbHelper.database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM progress WHERE word_id = ?', [wordId]),
      );
      return (count ?? 0) > 0;
    } catch (e) {
      debugPrint('❌ ProgressDao.exists error: $e');
      return false;
    }
  }
}