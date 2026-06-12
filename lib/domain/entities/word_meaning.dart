import 'package:equatable/equatable.dart';

class WordMeaning extends Equatable {
  final String partOfSpeech;
  final List<WordDefinition> definitions;

  const WordMeaning({
    required this.partOfSpeech,
    required this.definitions,
  });

  @override
  List<Object?> get props => [partOfSpeech, definitions];
}

class WordDefinition extends Equatable {
  final String definition;
  final String? example;
  final String phonetic;

  const WordDefinition({
    required this.definition,
    this.example,
    required this.phonetic,
  });

  @override
  List<Object?> get props => [definition, example, phonetic];
}
