import 'package:first_app/data/datasources/local/progress_dao.dart';
import 'package:first_app/data/datasources/local/word_batch_dao.dart';
import 'package:first_app/data/datasources/local/word_practice_dao.dart';
import 'package:first_app/data/datasources/local/DataBaseHelper.dart';
import 'package:first_app/data/datasources/local/daily_activity_dao.dart';
import 'package:first_app/data/datasources/local/user_dao.dart';
import 'package:first_app/domain/entities/progress.dart';
import 'package:first_app/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressDao _progressDao;
  final WordBatchDao _wordBatchDao;
  final WordPracticeDao _wordPracticeDao;
  final DailyActivityDao _dailyActivityDao;
  final UserDao _userDao;

  ProgressRepositoryImpl({
    required ProgressDao progressDao,
    required WordBatchDao wordBatchDao,
    required WordPracticeDao wordPracticeDao,
    required DailyActivityDao dailyActivityDao,
    required UserDao userDao,
  })  : _progressDao = progressDao,
        _wordBatchDao = wordBatchDao,
        _wordPracticeDao = wordPracticeDao,
        _dailyActivityDao = dailyActivityDao,
        _userDao = userDao;

  @override
  Future<Map<int, int>> getAllLearnCounts() async {
    return await _progressDao.getAllLearnCounts();
  }

  @override
  Future<void> batchUpdateLearnCounts(Map<int, int> updates) async {
    await _wordBatchDao.batchUpdateLearnCounts(updates);
  }

  @override
  Future<void> updateLearnCount(int word_id, int newLearn) async {
    await _wordPracticeDao.updateLearn(word_id, newLearn);
  }

  @override
  Future<Progress?> getByword_id(int word_id) async {
    final db = await DatabaseService().database;
    final rows = await db.query(
      'Word',
      columns: ['word', 'learn'],
      where: 'id = ?',
      whereArgs: [word_id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Progress(
      word_id: word_id,
      word: rows.first['word'] as String? ?? '',
      learn: rows.first['learn'] as int? ?? 0,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Progress>> getAll() async {
    final db = await DatabaseService().database;
    final rows = await db.rawQuery('''
      SELECT p.*, w.word FROM progress p
      LEFT JOIN Word w ON p.word_id = w.id
    ''');
    return rows.map((r) {
      return Progress(
        id: r['id'] as int?,
        word_id: r['word_id'] as int,
        word: r['word'] as String? ?? '',
        learn: r['learn'] as int? ?? 0,
        updatedAt: DateTime.parse(r['updated_at'] as String),
        userId: r['user_id'] as int?,
        syncedAt: r['synced_at'] != null ? DateTime.parse(r['synced_at'] as String) : null,
      );
    }).toList();
  }

  @override
  Future<List<Progress>> getWithLearnGreaterThanZero() async {
    final models = await _progressDao.getWithLearnGreaterThanZero();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Set<DateTime>> getPracticeDates() async {
    final userId = await _userDao.getUserId();
    if (userId == null) return {};
    return await _dailyActivityDao.getPracticeDates(userId);
  }

  @override
  Future<void> recordPracticeActivity() async {
    final userId = await _userDao.getUserId();
    if (userId == null) return;
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    await _dailyActivityDao.record(userId, date);
  }
}