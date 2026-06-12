import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/entities/sentence_model.dart';

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