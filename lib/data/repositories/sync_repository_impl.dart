import 'package:flutter/widgets.dart';
import 'package:first_app/data/datasources/local/outbox_dao.dart';
import 'package:first_app/data/datasources/local/user_dao.dart';
import 'package:first_app/data/datasources/local/progress_dao.dart';
import 'package:first_app/data/datasources/local/DataBaseHelper.dart';
import 'package:first_app/domain/entities/outbox_event.dart';
import 'package:first_app/domain/repositories/sync_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dio/dio.dart';

class SyncRepositoryImpl implements SyncRepository {
  final OutboxDao _outboxDao;
  final UserDao _userDao;
  final ProgressDao _progressDao;
  final Dio _dio;
  final String _baseUrl;

  SyncRepositoryImpl({
    required OutboxDao outboxDao,
    required UserDao userDao,
    required ProgressDao progressDao,
    required Dio dio,
    required String baseUrl,
  })  : _outboxDao = outboxDao,
        _userDao = userDao,
        _progressDao = progressDao,
        _dio = dio,
        _baseUrl = baseUrl;

  @override
  Future<int> countPending() => _outboxDao.countPending();

  @override
  Future<List<OutboxEvent>> selectReadyBatch(int limit) async {
    final now = DateTime.now().toIso8601String();
    final models = await _outboxDao.selectReadyBatch(limit, now);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markInFlight(List<int> ids) => _outboxDao.markInFlight(ids);

  @override
  Future<void> deleteByIds(List<int> ids) => _outboxDao.deleteByIds(ids);

  @override
  Future<void> markForRetry(List<int> ids, int attempts, int backoffSeconds) =>
      _outboxDao.markForRetry(ids, attempts, backoffSeconds);

  @override
  Future<void> markFailed(List<int> ids) => _outboxDao.markFailed(ids);

  int _calcBackoff(int attempt) {
    const cap = 86400;
    return (60 * (1 << (attempt - 1))).clamp(60, cap);
  }

  @override
  Future<bool> sync() async {
    try {
      final rows = await _outboxDao.selectReadyBatch(
        50,
        DateTime.now().toIso8601String(),
      );
      if (rows.isEmpty) return true;

      final ids = rows.map((r) => r.id!).toList();
      await _outboxDao.markInFlight(ids);

      final user = await _userDao.getSession();
      final token = user?['token'] as String?;
      if (token == null) {
        await _outboxDao.markFailed(ids);
        return false;
      }

      final batch = rows.map((r) {
        final payload = r.payloadAsMap;
        return {
          'word_id': r.entityId,
          'word': payload['word'] ?? '',
          'learn': payload['learn'],
          'updated_at': payload['updated_at'],
        };
      }).toList();

      try {
        await _dio.put(
          '$_baseUrl/progress',
          data: batch,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        await _outboxDao.deleteByIds(ids);
        await _setLastSyncTime(DateTime.now());
        await pullAndReconcile();
        return true;
      } catch (e) {
        final attempt = rows.first.attempts + 1;
        if (attempt >= rows.first.maxAttempts) {
          await _outboxDao.markFailed(ids);
        } else {
          await _outboxDao.markForRetry(ids, attempt, _calcBackoff(attempt));
        }
        return false;
      }
    } catch (e) {
      debugPrint('❌ SyncRepositoryImpl.sync error: $e');
      return false;
    }
  }

  @override
  Future<void> pullAndReconcile() async {
    try {
      final user = await _userDao.getSession();
      final token = user?['token'] as String?;
      final userId = user?['id'] as int?;
      if (token == null || userId == null) return;

      final response = await _dio.get(
        '$_baseUrl/progress',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode != 200) return;

      final serverItems = response.data as List<dynamic>;
      final now = DateTime.now().toIso8601String();

      for (final item in serverItems) {
        final wordId = item['word_id'] as int;
        final serverWord = item['word'] as String? ?? '';
        final serverLearn = item['learn'] as int;
        final serverUpdatedAt = item['updated_at'] as String;
        final local = await _progressDao.getLearnByWordId(wordId);

        if (local == null) {
          await _progressDao.updateFromServer(wordId, serverLearn, serverUpdatedAt, now);
          final db = await DatabaseService().database;
          await db.insert(
            'Word',
            {
              'id': wordId,
              'word': serverWord,
              'definition': '',
              'sentence': '',
              'learn': serverLearn,
              'created_at': serverUpdatedAt,
              'updated_at': serverUpdatedAt,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          await db.update(
            'Word',
            {'learn': serverLearn, 'updated_at': serverUpdatedAt},
            where: 'id = ?',
            whereArgs: [wordId],
          );
        } else {
          final localUpdatedAt = await _getLocalUpdatedAt(wordId);
          if (localUpdatedAt == null || serverUpdatedAt.compareTo(localUpdatedAt) > 0) {
            await _progressDao.updateFromServer(wordId, serverLearn, serverUpdatedAt, now);
            final db = await DatabaseService().database;
            await db.update(
              'Word',
              {'learn': serverLearn, 'updated_at': serverUpdatedAt},
              where: 'id = ?',
              whereArgs: [wordId],
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ SyncRepositoryImpl.pullAndReconcile error: $e');
    }
  }

  Future<String?> _getLocalUpdatedAt(int wordId) async {
    try {
      final db = await DatabaseService().database;
      final rows = await db.query(
        'progress',
        columns: ['updated_at'],
        where: 'word_id = ?',
        whereArgs: [wordId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first['updated_at'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final db = await DatabaseService().database;
      final rows = await db.rawQuery(
        "SELECT value FROM app_preferences WHERE key = 'last_sync_time'",
      );
      if (rows.isEmpty) return null;
      return DateTime.tryParse(rows.first['value'] as String);
    } catch (_) {
      return null;
    }
  }

  Future<void> _setLastSyncTime(DateTime time) async {
    try {
      final db = await DatabaseService().database;
      await db.insert(
        'app_preferences',
        {'key': 'last_sync_time', 'value': time.toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }
}