import 'package:first_app/domain/entities/word_stats.dart';
import 'package:first_app/domain/repositories/word_repository.dart';

class GetWordStatisticsUseCase {
  final WordRepository _repository;

  GetWordStatisticsUseCase(this._repository);

  static const int learnedThreshold = 100;
  static const int practiceMin = 1;

  Future<WordStats> call() async {
    final learnCounts = await _repository.getAllLearnCounts();
    final total = learnCounts.length;
    final newWords = learnCounts.where((c) => c == 0).length;
    final learnedWords = learnCounts.where((c) => c >= learnedThreshold).length;
    final practiceWords = total - newWords - learnedWords;

    return WordStats(
      totalWords: total,
      newWords: newWords,
      practiceWords: practiceWords,
      learnedWords: learnedWords,
    );
  }
}
