import 'package:equatable/equatable.dart';

class WordWithImage extends Equatable {
  final int id;
  final String word;
  final String definition;
  final String? tinyImageUrl;
  final int learn;

  const WordWithImage({
    required this.id,
    required this.word,
    required this.definition,
    this.tinyImageUrl,
    this.learn = 0,
  });

  @override
  List<Object?> get props => [id, word, definition, tinyImageUrl, learn];
}
