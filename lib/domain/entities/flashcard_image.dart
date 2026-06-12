import 'package:equatable/equatable.dart';

class FlashcardImage extends Equatable {
  final String url;
  final String? author;
  final String? source;

  const FlashcardImage({
    required this.url,
    this.author,
    this.source,
  });

  @override
  List<Object?> get props => [url, author, source];
}
