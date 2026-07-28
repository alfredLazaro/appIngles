import "dart:convert";
import "package:flutter/widgets.dart";
import "package:sqflite/sqflite.dart";
import "DataBaseHelper.dart";
import "package:first_app/data/models/outbox_event_model.dart";

class OutboxDao {
  final dbHelper = DatabaseService();

  Future<int> countPending() async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery(
        "SELECT COUNT(*) as c FROM outbox WHERE status = 'pending' AND (next_retry_at IS NULL OR next_retry_at <= datetime('now'))",
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('❌ OutboxDao.countPending error: $e');
      return 0;
    }
  }

  Future<List<OutboxEventModel>> selectReadyBatch(int limit, String now) async {
    try {
      final db = await dbHelper.database;
      final rows = await db.rawQuery('''
        SELECT * FROM outbox
        WHERE status = 'pending'
          AND (next_retry_at IS NULL OR next_retry_at <= ?)
        ORDER BY created_at ASC
        LIMIT ?
      ''', [now, limit]);
      return rows.map((r) => OutboxEventModel.fromMap(r)).toList();
    } catch (e) {
      debugPrint('❌ OutboxDao.selectReadyBatch error: $e');
      return [];
    }
  }

  Future<void> markInFlight(List<int> ids) async {
    try {
      final db = await dbHelper.database;
      final now = DateTime.now().toIso8601String();
      final placeholders = ids.map((_) => '?').join(',');
      await db.rawUpdate(
        "UPDATE outbox SET status = 'in_flight', updated_at = ? WHERE id IN ($placeholders)",
        [now, ...ids],
      );
    } catch (e) {
      debugPrint('❌ OutboxDao.markInFlight error: $e');
      rethrow;
    }
  }

  Future<void> deleteByIds(List<int> ids) async {
    try {
      final db = await dbHelper.database;
      final placeholders = ids.map((_) => '?').join(',');
      await db.rawDelete('DELETE FROM outbox WHERE id IN ($placeholders)', ids);
    } catch (e) {
      debugPrint('❌ OutboxDao.deleteByIds error: $e');
      rethrow;
    }
  }

  Future<void> markForRetry(List<int> ids, int attempts, int backoffSeconds) async {
    try {
      final db = await dbHelper.database;
      final now = DateTime.now().toIso8601String();
      final placeholders = ids.map((_) => '?').join(',');
      await db.rawUpdate('''
        UPDATE outbox
        SET status = 'pending',
            attempts = ?,
            next_retry_at = datetime('now', '+$backoffSeconds seconds'),
            updated_at = ?
        WHERE id IN ($placeholders)
      ''', [attempts, now, ...ids]);
    } catch (e) {
      debugPrint('❌ OutboxDao.markForRetry error: $e');
      rethrow;
    }
  }

  Future<void> markFailed(List<int> ids) async {
    try {
      final db = await dbHelper.database;
      final now = DateTime.now().toIso8601String();
      final placeholders = ids.map((_) => '?').join(',');
      await db.rawUpdate(
        "UPDATE outbox SET status = 'failed', updated_at = ? WHERE id IN ($placeholders)",
        [now, ...ids],
      );
    } catch (e) {
      debugPrint('❌ OutboxDao.markFailed error: $e');
      rethrow;
    }
  }

  /// Encola o colapsa (si ya existe un pending para la misma entidad)
  Future<void> enqueueInTransaction(
    Database txn,
    String entityType,
    int entityId,
    Map<String, dynamic> payload,
    String now,
  ) async {
    final existing = await txn.query(
      'outbox',
      where: "entity_type = ? AND entity_id = ? AND status = 'pending'",
      whereArgs: [entityType, entityId],
    );

    if (existing.isEmpty) {
      await txn.insert('outbox', {
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': 'upsert',
        'payload': jsonEncode(payload),
        'status': 'pending',
        'created_at': now,
        'updated_at': now,
      });
    } else {
      await txn.update(
        'outbox',
        {
          'payload': jsonEncode(payload),
          'updated_at': now,
          'attempts': 0,
          'next_retry_at': null,
        },
        where: "entity_type = ? AND entity_id = ? AND status = 'pending'",
        whereArgs: [entityType, entityId],
      );
    }
  }
}