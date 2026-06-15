import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/translation_entity.dart';

class MatchRound extends Equatable {
  final List<FlashcardWord> words;
  final List<TranslationEntity> translations;
  final Map<int, int> correctMapping;

  const MatchRound({
    required this.words,
    required this.translations,
    required this.correctMapping,
  });

  static List<MatchRound> generateRounds({
    required List<FlashcardWord> allWords,
    required List<TranslationEntity> allTranslations,
    int batchSize = 4,
  }) {
    final rounds = <MatchRound>[];
    final random = Random();

    // Agrupar traducciones por wordId
    final Map<int, List<TranslationEntity>> translationsByWordId = {};
    for (final translation in allTranslations) {
      translationsByWordId
          .putIfAbsent(translation.wordId, () => [])
          .add(translation);
    }

    // Filtrar palabras que NO tienen traducciones (no se pueden usar)
    final validWords = allWords.where((word) {
      final hasTranslations = translationsByWordId.containsKey(word.id);
      if (!hasTranslations) {
        print(
            '⚠️ Palabra " ${word.word} " no tiene traducciones y será omitida');
      }
      return hasTranslations;
    }).toList();

    for (int i = 0; i < validWords.length; i += batchSize) {
      final end = (i + batchSize < validWords.length)
          ? i + batchSize
          : validWords.length;
      final batchWords = validWords.sublist(i, end);

      // Seleccionar UNA traducción al azar por palabra
      final Map<int, TranslationEntity> selectedTranslations = {};
      final List<TranslationEntity> batchTranslations = [];

      for (final word in batchWords) {
        final translations = translationsByWordId[word.id]!;
        // Selección aleatoria
        final selected = translations[random.nextInt(translations.length)];
        selectedTranslations[word.id] = selected;
        batchTranslations.add(selected);
      }

      // Mezclar traducciones
      final shuffledTranslations =
          List<TranslationEntity>.from(batchTranslations)..shuffle(random);

      // Crear mapeo correcto
      final correctMapping = <int, int>{};
      for (int wi = 0; wi < batchWords.length; wi++) {
        final wordId = batchWords[wi].id;
        final selectedId = selectedTranslations[wordId]!.id;
        final ti = shuffledTranslations.indexWhere((t) => t.id == selectedId);
        correctMapping[wi] = ti;
      }

      rounds.add(MatchRound(
        words: batchWords,
        translations: shuffledTranslations,
        correctMapping: correctMapping,
      ));
    }

    return rounds;
  }

  @override
  List<Object?> get props => [words, translations, correctMapping];
}
