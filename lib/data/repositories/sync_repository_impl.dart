import 'package:flutter/widgets.dart';
import 'package:first_app/data/datasources/local/outbox_dao.dart';
import 'package:first_app/data/datasources/local/user_dao.dart';
import 'package:first_app/data/datasources/local/progress_dao.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';
import 'package:first_app/data/datasources/local/translation_dao.dart';
import 'package:first_app/data/datasources/local/daily_activity_dao.dart';
import 'package:first_app/data/datasources/local/DataBaseHelper.dart';
import 'package:first_app/data/datasources/remote/progress_service.dart';
import 'package:first_app/data/models/image_model.dart';
import 'package:first_app/domain/entities/outbox_event.dart';
import 'package:first_app/domain/repositories/sync_repository.dart';
import 'package:sqflite/sqflite.dart';

class SyncRepositoryImpl implements SyncRepository {
  static const String _activityEntityType = 'daily_activity';

  final OutboxDao _outboxDao;
  final UserDao _userDao;
  final ProgressDao _progressDao;
  final ProgressService _progressService;
  final ImageDao _imageDao;
  final TranslationDao _translationDao;
  final DailyActivityDao _dailyActivityDao;

  SyncRepositoryImpl({
    required OutboxDao outboxDao,
    required UserDao userDao,
    required ProgressDao progressDao,
    required ProgressService progressService,
    required ImageDao imageDao,
    required TranslationDao translationDao,
    required DailyActivityDao dailyActivityDao,
  })  : _outboxDao = outboxDao,
        _userDao = userDao,
        _progressDao = progressDao,
        _progressService = progressService,
        _imageDao = imageDao,
        _translationDao = translationDao,
        _dailyActivityDao = dailyActivityDao;

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

      final progressIds = <int>[];
      final progressBatch = <Map<String, dynamic>>[];
      final activityIds = <int>[];
      final activityBatch = <Map<String, dynamic>>[];

      for (final r in rows) {
        final payload = r.payloadAsMap;
        if (r.entityType == _activityEntityType) {
          activityIds.add(r.id!);
          activityBatch.add({
            'user_id': payload['user_id'],
            'date': payload['date'],
          });
        } else {
          progressIds.add(r.id!);
          progressBatch.add({
            'word_id': r.entityId,
            'word': payload['word'] ?? '',
            'learn': payload['learn'],
            'updated_at': payload['updated_at'],
          });
        }
      }

      var allOk = true;

      if (progressBatch.isNotEmpty) {
        allOk = await _pushProgress(progressIds, progressBatch, token) && allOk;
      }

      if (activityBatch.isNotEmpty) {
        allOk = await _pushDailyActivity(activityIds, activityBatch, token) && allOk;
      }

      if (allOk) {
        await _setLastSyncTime(DateTime.now());
        await pullAndReconcile();
      }
      return allOk;
    } catch (e) {
      debugPrint('❌ SyncRepositoryImpl.sync error: $e');
      return false;
    }
  }

  Future<bool> _pushProgress(
    List<int> ids,
    List<Map<String, dynamic>> batch,
    String token,
  ) async {
    try {
      await _progressService.pushProgress(batch, token);
      await _outboxDao.deleteByIds(ids);
      return true;
    } catch (e) {
      await _markForRetryOrFail(ids);
      return false;
    }
  }

  Future<bool> _pushDailyActivity(
    List<int> ids,
    List<Map<String, dynamic>> batch,
    String token,
  ) async {
    try {
      await _progressService.pushDailyActivity(batch, token);
      await _outboxDao.deleteByIds(ids);
      return true;
    } catch (e) {
      await _markForRetryOrFail(ids);
      return false;
    }
  }

  Future<void> _markForRetryOrFail(List<int> ids) async {
    final rows = await _outboxDao.selectByIds(ids);
    if (rows.isEmpty) return;
    final attempt = rows.first.attempts + 1;
    if (attempt >= rows.first.maxAttempts) {
      await _outboxDao.markFailed(ids);
    } else {
      await _outboxDao.markForRetry(ids, attempt, _calcBackoff(attempt));
    }
  }

  @override
  Future<void> pullAndReconcile() async {
    try {
      final user = await _userDao.getSession();
      final token = user?['token'] as String?;
      final userId = user?['id'] as int?;
      if (token == null || userId == null) return;

      final serverItems = await _progressService.pullProgress(token);
      final now = DateTime.now().toIso8601String();

      for (final item in serverItems) {
        final word_id = item['word_id'] as int;
        final serverWord = item['word'] as String;
        final serverLearn = item['learn'] as int;
        final serverUpdatedAt = item['updated_at'] as String;
        final local = await _progressDao.getLearnByword_id(word_id);

        if (local == null) {
          await _progressDao.updateFromServer(word_id, serverLearn, serverWord, serverUpdatedAt, now);
        } else {
          final localUpdatedAt = await _getLocalUpdatedAt(word_id);
          if (localUpdatedAt == null || serverUpdatedAt.compareTo(localUpdatedAt) > 0) {
            await _progressDao.updateFromServer(word_id, serverLearn, serverWord, serverUpdatedAt, now);
            final db = await DatabaseService().database;
            await db.update(
              'Word',
              {'learn': serverLearn, 'updated_at': serverUpdatedAt, 'word': serverWord},
              where: 'id = ?',
              whereArgs: [word_id],
            );
          }
        }
      }

      await _pullAndMergeDailyActivity(token, userId);
    } catch (e) {
      debugPrint('❌ SyncRepositoryImpl.pullAndReconcile error: $e');
    }
  }

  Future<void> _pullAndMergeDailyActivity(String token, int userId) async {
    try {
      final activities = await _progressService.pullDailyActivity(token);
      if (activities.isEmpty) return;
      final dates = <DateTime>{};
      for (final item in activities) {
        final date = item['date'] as String?;
        if (date == null || date.length < 10) continue;
        final parts = date.split('-');
        dates.add(DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        ));
      }
      if (dates.isNotEmpty) {
        await _dailyActivityDao.mergeDates(userId, dates);
      }
    } catch (e) {
      debugPrint('❌ SyncRepositoryImpl._pullAndMergeDailyActivity error: $e');
    }
  }

  Future<String?> _getLocalUpdatedAt(int word_id) async {
    try {
      final db = await DatabaseService().database;
      final rows = await db.query(
        'progress',
        columns: ['updated_at'],
        where: 'word_id = ?',
        whereArgs: [word_id],
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

  @override
  Future<void> pullWordsByCategory(String category) async {
    try {
      final user = await _userDao.getSession();
      final token = user?['token'] as String?;
      if (token == null) return;

      final words = await _progressService.getWordsByCategory(token, category);
      if (words.isEmpty) return;

      final now = DateTime.now().toIso8601String();
      final newIds = <int>[];

      final db = await DatabaseService().database;
      await db.transaction((txn) async {
        for (final w in words) {
          final wordText = (w['word'] as String?)?.trim() ?? '';
          if (wordText.isEmpty) continue;

          final count = Sqflite.firstIntValue(
            await txn.rawQuery(
              'SELECT COUNT(*) FROM Word WHERE word = ?',
              [wordText],
            ),
          ) ?? 0;
          if (count > 0) continue;

          final word_id = w['id'] as int;
          newIds.add(word_id);

          await txn.insert('Word', {
            'id': word_id,
            'word': wordText,
            'partOfSpeech': w['part_of_speech'] ?? '',
            'phonetic': w['phonetic'] ?? '',
            'definition': w['definition'] ?? '',
            'sentence': w['sentence'] ?? '',
            'learn': w['learn'] ?? 0,
            'synonyms': w['synonyms'] ?? '',
            'created_at': w['created_at'] ?? now,
            'updated_at': w['updated_at'] ?? now,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await txn.insert('progress', {
            'word_id': word_id,
            'word': wordText,
            'learn': w['learn'] ?? 0,
            'updated_at': now,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });

      if (newIds.isEmpty) return;

      final translations = await _progressService.getTranslationsByWordsIds(token, newIds);
      if (translations.isNotEmpty) {
        await _translationDao.batchInsertTranslations(
          translations.cast<Map<String, dynamic>>(),
        );
      }

      final images = await _progressService.getImagesByWordsIds(token, newIds);
      if (images.isNotEmpty) {
        for (final img in images) {
          await _imageDao.insertImage(Image_Model(
            id: img['id'],
            word_id: img['word_id'],
            name: img['name'] as String? ?? '',
            url: img['url'],
            tinyurl: img['tinyurl'],
            author: img['author'],
            source: img['source'],
          ));
        }
      }
    } catch (e) {
      debugPrint('❌ SyncRepositoryImpl.pullWordsByCategory error: $e');
    }
  }
}