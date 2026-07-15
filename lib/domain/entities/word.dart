import 'package:equatable/equatable.dart';

class Word extends Equatable {
  final int? id;
  final String word;
  final String partOfSpeech;
  final String phonetic;
  final String definition;
  final String sentence;
  final int learnCount;
  final String synonyms;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Word({
    this.id,
    required this.word,
    required this.partOfSpeech,
    required this.phonetic,
    required this.definition,
    required this.sentence,
    this.learnCount = 0,
    this.synonyms = '',
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        word,
        partOfSpeech,
        phonetic,
        definition,
        sentence,
        learnCount,
        synonyms,
        createdAt,
        updatedAt,
      ];

  Word copyWith({
    int? id,
    String? word,
    String? partOfSpeech,
    String? phonetic,
    String? definition,
    String? sentence,
    int? learnCount,
    String? synonyms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      phonetic: phonetic ?? this.phonetic,
      definition: definition ?? this.definition,
      sentence: sentence ?? this.sentence,
      learnCount: learnCount ?? this.learnCount,
      synonyms: synonyms ?? this.synonyms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
