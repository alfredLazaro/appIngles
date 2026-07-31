import 'package:equatable/equatable.dart';

class TranslationWithWord extends Equatable {
  final int translationId;
  final String wordTranslate;
  final String? alternatives;
  final String word;
  final String definition;

  const TranslationWithWord({
    required this.translationId,
    required this.wordTranslate,
    this.alternatives,
    required this.word,
    required this.definition,
  });

  factory TranslationWithWord.fromMap(Map<String, dynamic> map) {
    return TranslationWithWord(
      translationId: map['id'] as int,
      wordTranslate: map['word_translate'] as String,
      alternatives: map['alternatives'] as String?,
      word: map['word'] as String,
      definition: map['definition'] as String,
    );
  }

  @override
  List<Object?> get props =>
      [translationId, wordTranslate, alternatives, word, definition];

  @override
  String toString() {
    return 'TranslationWithWord(id: $translationId, translate: $wordTranslate, word: $word)';
  }
}