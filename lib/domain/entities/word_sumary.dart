/// Entidad ligera para listas (sin datos completos)
class WordSummary {
  final int id;
  final String word;
  final String sentence;

  const WordSummary({
    required this.id,
    required this.word,
    required this.sentence,
  });
}
