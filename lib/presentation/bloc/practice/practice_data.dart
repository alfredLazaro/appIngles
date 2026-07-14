import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/entities/sentence_model.dart';
import 'package:first_app/domain/entities/match_round.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';

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

class MatchingDefPracticeData extends PracticeData {
  final List<FlashcardWord> words;
  final List<MatchRound> rounds;

  const MatchingDefPracticeData({
    required this.words,
    required this.rounds,
  });
}

class ListeningPracticeData extends PracticeData {
  final List<FlashcardWord> words;
  final int maxAudioPlays;

  const ListeningPracticeData({
    required this.words,
    this.maxAudioPlays = 0,
  });
}

class PracticeResult {
  final PracticeType type;
  final Map<int, int> learnCountUpdates;
  final int totalItems;
  final int correctItems;

  const PracticeResult({
    required this.type,
    required this.learnCountUpdates,
    required this.totalItems,
    required this.correctItems,
  });
}