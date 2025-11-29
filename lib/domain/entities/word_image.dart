class WordImage {
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
}
