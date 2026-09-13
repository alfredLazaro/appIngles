import 'dart:developer';
import 'package:first_app/data/datasources/local/app_preferences_dao.dart';
import 'package:first_app/data/datasources/local/word_batch_dao.dart';
import 'package:first_app/domain/repositories/progress_repository.dart';
import 'package:first_app/core/utils/learn_decay_calculator.dart';

class LearnDecayService {
  final ProgressRepository _progressRepository;
  final WordBatchDao _wordBatchDao;
  final AppPreferencesDao _preferencesDao;

  LearnDecayService({
    required ProgressRepository progressRepository,
    required WordBatchDao wordBatchDao,
  })  : _progressRepository = progressRepository,
        _wordBatchDao = wordBatchDao,
        _preferencesDao = AppPreferencesDao();

  static const String _lastRunKey = 'last_decay_run_date';

  Future<void> runCheck() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastRun = await _preferencesDao.getString(_lastRunKey);
    if (lastRun == todayStr) return;

    try {
      final updates = await _computeUpdates();
      if (updates.isNotEmpty) {
        await _wordBatchDao.applyDecayUpdates(updates);
      }
      await _preferencesDao.setString(_lastRunKey, todayStr);
    } catch (e) {
      print('❌ LearnDecayService error: $e');
    }
  }

  Future<Map<int, int>> _computeUpdates() async {
    final now = DateTime.now();
    final candidates = await _progressRepository.getDecayCandidates();
    final updates = <int, int>{};

    for (final candidate in candidates) {
      final daysNotPracticed =
          LearnDecayCalculator.daysSince(candidate.lastPracticed, now);
      if (daysNotPracticed <= 0) continue;
      if (!LearnDecayCalculator.isCandidate(candidate.learn)) continue;

      final newLearn =
          LearnDecayCalculator.decayedLearn(candidate.learn, daysNotPracticed);
      if (newLearn != candidate.learn) {
        updates[candidate.wordId] = newLearn;
      }
    }

    return updates;
  }
}
