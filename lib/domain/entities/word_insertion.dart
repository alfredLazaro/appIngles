import 'package:equatable/equatable.dart';

class WordInsertion extends Equatable {
  final String word;
  final String phonetic;
  final String definition;
  final String sentence;

  const WordInsertion({
    required this.word,
    required this.phonetic,
    required this.definition,
    required this.sentence,
  });

  @override
  List<Object?> get props => [word, phonetic, definition, sentence];
}
