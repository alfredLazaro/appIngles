import 'package:first_app/data/datasources/local/progress_dao.dart';
import 'package:first_app/data/datasources/local/word_batch_dao.dart';
import 'package:first_app/data/datasources/local/word_practice_dao.dart';
import 'package:first_app/domain/entities/progress.dart';
import 'package:first_app/domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressDao _progressDao;
  final WordBatchDao _wordBatchDao;
  final WordPracticeDao _wordPracticeDao;

  ProgressRepositoryImpl({
    required ProgressDao progressDao,
    required WordBatchDao wordBatchDao,
    required WordPracticeDao wordPracticeDao,
  })  : _progressDao = progressDao,
        _wordBatchDao = wordBatchDao,
        _wordPracticeDao = wordPracticeDao;

  @override
  Future<Map<int, int>> getAllLearnCounts() async {
    return await _progressDao.getAllLearnCounts();
  }

  @override
  Future<void> batchUpdateLearnCounts(Map<int, int> updates) async {
    await _wordBatchDao.batchUpdateLearnCounts(updates);
  }

  @override
  Future<void> updateLearnCount(int wordId, int newLearn) async {
    await _wordPracticeDao.updateLearn(wordId, newLearn);
  }

  @override
  Future<Progress?> getByWordId(int wordId) async {
    final learn = await _progressDao.getLearnByWordId(wordId);
    if (learn == null) return null;
    return Progress(
      wordId: wordId,
      learn: learn,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<Progress>> getAll() async {
    final rows = await _progressDao.getAll();
    return rows.map((r) {
      return Progress(
        id: r['id'] as int?,
        wordId: r['word_id'] as int,
        learn: r['learn'] as int? ?? 0,
        updatedAt: DateTime.parse(r['updated_at'] as String),
        userId: r['user_id'] as int?,
        syncedAt: r['synced_at'] != null ? DateTime.parse(r['synced_at'] as String) : null,
      );
    }).toList();
  }
}