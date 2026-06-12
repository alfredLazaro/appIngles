import 'package:equatable/equatable.dart';

class WordSummary extends Equatable {
  final int id;
  final String word;
  final String sentence;

  const WordSummary({
    required this.id,
    required this.word,
    required this.sentence,
  });

  @override
  List<Object?> get props => [id, word, sentence];
}
