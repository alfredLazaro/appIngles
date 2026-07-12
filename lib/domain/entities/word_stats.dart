import 'package:equatable/equatable.dart';

class WordStats extends Equatable {
  final int totalWords;
  final int newWords;
  final int practiceWords;
  final int learnedWords;

  const WordStats({
    required this.totalWords,
    required this.newWords,
    required this.practiceWords,
    required this.learnedWords,
  });

  double get newPercentage =>
      totalWords > 0 ? (newWords / totalWords) * 100 : 0;
  double get practicePercentage =>
      totalWords > 0 ? (practiceWords / totalWords) * 100 : 0;
  double get learnedPercentage =>
      totalWords > 0 ? (learnedWords / totalWords) * 100 : 0;

  @override
  List<Object?> get props =>
      [totalWords, newWords, practiceWords, learnedWords];

  @override
  String toString() {
    return 'WordStats(total: $totalWords, new: $newWords, practice: $practiceWords, learned: $learnedWords)';
  }
}