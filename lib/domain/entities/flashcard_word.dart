/// Entidad pura sin dependencias externas
class FlashcardWord {
  final String word;
  final String definition;
  final String sentence;
  final int learnCount;

  const FlashcardWord({
    required this.word,
    required this.definition,
    required this.sentence,
    this.learnCount = 0,
  });

  FlashcardWord copyWith({
    String? word,
    String? definition,
    String? sentence,
    int? learnCount,
  }) {
    return FlashcardWord(
      word: word ?? this.word,
      definition: definition ?? this.definition,
      sentence: sentence ?? this.sentence,
      learnCount: learnCount ?? this.learnCount,
    );
  }
}
