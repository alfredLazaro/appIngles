/// Entidad para mostrar palabra con su primera imagen
class WordWithImage {
  final int id;
  final String word;
  final String definition;
  final String? tinyImageUrl; // Opcional por si no hay imagen
  final int learn;
  const WordWithImage({
    required this.id,
    required this.word,
    required this.definition,
    this.tinyImageUrl,
    this.learn = 0,
  });
}
