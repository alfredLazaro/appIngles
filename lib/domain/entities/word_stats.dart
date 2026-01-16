class WordStats {
  final int totalWords;
  final int newWords;        // learn = 0
  final int practiceWords;   // learn >= 1 and learn < 100
  final int learnedWords;    // learn >= 100

  const WordStats({
    required this.totalWords,
    required this.newWords,
    required this.practiceWords,
    required this.learnedWords,
  });

  // Calculate percentage
  double get newPercentage => totalWords > 0 ? (newWords / totalWords) * 100 : 0;
  double get practicePercentage => totalWords > 0 ? (practiceWords / totalWords) * 100 : 0;
  double get learnedPercentage => totalWords > 0 ? (learnedWords / totalWords) * 100 : 0;

  @override
  String toString() {
    return 'WordStats(total: $totalWords, new: $newWords, practice: $practiceWords, learned: $learnedWords)';
  }
}