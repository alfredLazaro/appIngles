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

    for (int i = 0; i < allWords.length; i += batchSize) {
      final end = (i + batchSize < allWords.length)
          ? i + batchSize
          : allWords.length;
      final batchWords = allWords.sublist(i, end);

      final usedWordIds = batchWords.map((w) => w.id).toSet();

      final batchTranslations = allTranslations
          .where((t) => usedWordIds.contains(t.wordId))
          .toList();

      if (batchTranslations.length != batchWords.length) {
        continue;
      }

      final shuffledTranslations = List<TranslationEntity>.from(batchTranslations)
        ..shuffle(random);

      final correctMapping = <int, int>{};
      for (int wi = 0; wi < batchWords.length; wi++) {
        final wordId = batchWords[wi].id;
        final ti = shuffledTranslations
            .indexWhere((t) => t.wordId == wordId);
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
