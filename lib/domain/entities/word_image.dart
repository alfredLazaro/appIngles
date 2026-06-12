import 'package:equatable/equatable.dart';

class WordImage extends Equatable {
  final int? id;
  final int wordId;
  final String url;
  final String tinyUrl;
  final String name;
  final String author;
  final String source;

  const WordImage({
    this.id,
    required this.wordId,
    required this.url,
    required this.tinyUrl,
    required this.name,
    required this.author,
    required this.source,
  });

  @override
  List<Object?> get props =>
      [id, wordId, url, tinyUrl, name, author, source];
}
