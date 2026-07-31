import 'package:equatable/equatable.dart';

class FlashcardWord extends Equatable {
  final int id;
  final String word;
  final String partOfSpeech;
  final String phonetic;
  final String definition;
  final String sentence;
  final int learnCount;

  const FlashcardWord({
    required this.id,
    required this.word,
    this.partOfSpeech = '',
    this.phonetic = '',
    required this.definition,
    required this.sentence,
    this.learnCount = 0,
  });

  @override
  List<Object?> get props =>
      [id, word, partOfSpeech, phonetic, definition, sentence, learnCount];

  FlashcardWord copyWith({
    String? word,
    String? partOfSpeech,
    String? phonetic,
    String? definition,
    String? sentence,
    int? learnCount,
  }) {
    return FlashcardWord(
      id: id,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      phonetic: phonetic ?? this.phonetic,
      definition: definition ?? this.definition,
      sentence: sentence ?? this.sentence,
      learnCount: learnCount ?? this.learnCount,
    );
  }
}
