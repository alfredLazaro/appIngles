// domain/entities/translation_with_word.dart
class TranslationWithWord {
  final int translationId;
  final String wordTranslate;
  final String? alternatives;
  final String word;
  final String definition;

  TranslationWithWord({
    required this.translationId,
    required this.wordTranslate,
    this.alternatives,
    required this.word,
    required this.definition,
  });

  factory TranslationWithWord.fromMap(Map<String, dynamic> map) {
    return TranslationWithWord(
      translationId: map['id'] as int,
      wordTranslate: map['wordTranslate'] as String,
      alternatives: map['alternatives'] as String?,
      word: map['word'] as String,
      definition: map['definition'] as String,
    );
  }

  @override
  String toString() {
    return 'TranslationWithWord(id: $translationId, translate: $wordTranslate, word: $word)';
  }
}