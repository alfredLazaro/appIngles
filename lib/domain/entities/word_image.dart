import 'package:equatable/equatable.dart';

class WordImage extends Equatable {
  final int? id;
  final int word_id;
  final String url;
  final String tinyUrl;
  final String name;
  final String author;
  final String source;

  const WordImage({
    this.id,
    required this.word_id,
    required this.url,
    required this.tinyUrl,
    required this.name,
    required this.author,
    required this.source,
  });

  @override
  List<Object?> get props =>
      [id, word_id, url, tinyUrl, name, author, source];
}
