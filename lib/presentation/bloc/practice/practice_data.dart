import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/entities/sentence_model.dart';
import 'package:first_app/domain/entities/match_round.dart';

abstract class PracticeData {
  const PracticeData();
}

class FlashcardPracticeData extends PracticeData {
  final List<FlashcardWord> words;
  final Map<int, List<FlashcardImage>> imagesMap;

  const FlashcardPracticeData({
    required this.words,
    required this.imagesMap,
  });
}

class SentencePracticeData extends PracticeData {
  final List<SentenceModel> sentences;

  const SentencePracticeData({
    required this.sentences,
  });
}

class MatchingPracticeData extends PracticeData {
  final List<FlashcardWord> words;
  final List<MatchRound> rounds;

  const MatchingPracticeData({
    required this.words,
    required this.rounds,
  });
}