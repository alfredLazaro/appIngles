import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/entities/word_def.dart';

class MatchRound extends Equatable {
  final List<FlashcardWord> words;
  final List<TranslationEntity> translations;
  final Map<int, int> correctMapping;
  final List<String>? definitions;

  const MatchRound({
    required this.words,
    required this.translations,
    required this.correctMapping,
    this.definitions,
  });

  static List<MatchRound> generateRounds({
    required List<FlashcardWord> allWords,
    required List<TranslationEntity> allTranslations,
    int batchSize = 4,
  }) {
    final random = Random();

    final translationsByWordId = <int, List<TranslationEntity>>{};
    for (final t in allTranslations) {
      translationsByWordId.putIfAbsent(t.wordId, () => []).add(t);
    }

    final validWords =
        allWords.where((w) => translationsByWordId.containsKey(w.id)).toList();

    final batches = _createBatches(validWords, batchSize);

    return batches.map((batchWords) {
      // Una traducción al azar por palabra, elegida una sola vez (no en cada shuffle)
      final selectedByWordId = <int, TranslationEntity>{
        for (final word in batchWords)
          word.id: translationsByWordId[word.id]![
              random.nextInt(translationsByWordId[word.id]!.length)],
      };

      final (shuffled, correctMapping) =
          _shuffleAndMap<FlashcardWord, TranslationEntity, int>(
        batch: batchWords,
        optionOf: (word) => selectedByWordId[word.id]!,
        keyOf: (t) => t.id!,
        random: random,
      );

      return MatchRound(
        words: batchWords,
        translations: shuffled,
        correctMapping: correctMapping,
      );
    }).toList();
  }

  static List<MatchRound> generateDefRounds({
    required List<WordDef> allWords,
    int batchSize = 4,
  }) {
    final random = Random();
    final batches = _createBatches(allWords, batchSize);

    return batches.map((batchWords) {
      final (shuffled, correctMapping) =
          _shuffleAndMap<WordDef, String, String>(
        batch: batchWords,
        optionOf: (wd) => wd.definition,
        keyOf: (def) => def,
        random: random,
      );

      final flashcardWords = batchWords
          .map((wd) => FlashcardWord(
                id: wd.id,
                word: wd.word,
                definition: wd.definition,
                sentence: '',
              ))
          .toList();

      return MatchRound(
        words: flashcardWords,
        translations: const [],
        definitions: shuffled,
        correctMapping: correctMapping,
      );
    }).toList();
  }

  /// Divide [items] en lotes de tamaño [batchSize].
  /// Si el último lote quedaría con un único elemento, lo fusiona
  /// con el lote anterior para evitar dejarlo solo.
  static List<List<T>> _createBatches<T>(List<T> items, int batchSize) {
    final batches = <List<T>>[];
    int i = 0;
    while (i < items.length) {
      final remaining = items.length - i;

      final currentBatchSize =
          (remaining > batchSize && remaining - batchSize == 1)
              ? batchSize + 1
              : (remaining < batchSize ? remaining : batchSize);

      final end = i + currentBatchSize;
      batches.add(items.sublist(i, end));
      i = end;
    }
    return batches;
  }

  /// Para cada item del batch obtiene su "opción" (vía [optionOf]), las mezcla,
  /// y devuelve tanto la lista mezclada como el mapeo índice-original -> índice-mezclado,
  /// usando [keyOf] para identificar coincidencias.
  static (List<O>, Map<int, int>) _shuffleAndMap<T, O, K>({
    required List<T> batch,
    required O Function(T item) optionOf,
    required K Function(O option) keyOf,
    required Random random,
  }) {
    final options = batch.map(optionOf).toList();
    final shuffled = List<O>.from(options)..shuffle(random);

    final correctMapping = <int, int>{};
    for (int wi = 0; wi < batch.length; wi++) {
      final targetKey = keyOf(options[wi]);
      correctMapping[wi] = shuffled.indexWhere((o) => keyOf(o) == targetKey);
    }
    return (shuffled, correctMapping);
  }

  @override
  List<Object?> get props => [words, translations, correctMapping, definitions];
}
