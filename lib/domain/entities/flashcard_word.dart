import 'package:equatable/equatable.dart';

class FlashcardWord extends Equatable {
  final int id;
  final String word;
  final String definition;
  final String sentence;
  final int learnCount;

  const FlashcardWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.sentence,
    this.learnCount = 0,
  });

  @override
  List<Object?> get props => [id, word, definition, sentence, learnCount];

  FlashcardWord copyWith({
    String? word,
    String? definition,
    String? sentence,
    int? learnCount,
  }) {
    return FlashcardWord(
      id: id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      sentence: sentence ?? this.sentence,
      learnCount: learnCount ?? this.learnCount,
    );
  }
}
