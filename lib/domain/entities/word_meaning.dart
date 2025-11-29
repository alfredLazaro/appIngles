/// Entidad que representa un significado de la API
class WordMeaning {
  final String partOfSpeech;
  final List<WordDefinition> definitions;

  const WordMeaning({
    required this.partOfSpeech,
    required this.definitions,
  });
}

class WordDefinition {
  final String definition;
  final String? example;

  const WordDefinition({
    required this.definition,
    this.example,
  });
}
