class ImageSearchResult {
  final String id;
  final String regularUrl;
  final String thumbUrl;
  final String author;
  final String description;

  const ImageSearchResult({
    required this.id,
    required this.regularUrl,
    required this.thumbUrl,
    required this.author,
    this.description = 'Unsplash',
  });
}
