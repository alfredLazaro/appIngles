/// Entidad pura de palabra (sin dependencias externas)
class WordInsertion {
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
}
