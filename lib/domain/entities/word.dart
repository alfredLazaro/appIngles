import 'package:equatable/equatable.dart';

class Word extends Equatable {
  final int? id;
  final String word;
  final String partOfSpeech; // Added partOfSpeech field to represent the part of speech of the word 
  final String phonetic;
  final String definition;
  final String sentence;
  final int learnCount;
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
