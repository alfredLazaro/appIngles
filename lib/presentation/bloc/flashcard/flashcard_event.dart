import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';

abstract class FlashcardEvent extends Equatable {
  const FlashcardEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSession extends FlashcardEvent {
  final List<FlashcardWord> words;
  final Map<int, List<FlashcardImage>> imagesMap;
  final int batchSize;

  const InitializeSession({
    required this.words,
    required this.imagesMap,
    this.batchSize = 3,
  });

  @override
  List<Object?> get props => [words, imagesMap, batchSize];
}

class NextFlashcard extends FlashcardEvent {}

class PreviousFlashcard extends FlashcardEvent {}

class FlipFlashcard extends FlashcardEvent {}

class IncrementLearnCount extends FlashcardEvent {
  final int? amount;

  const IncrementLearnCount({this.amount});
}

class DecrementLearnCount extends FlashcardEvent {
  final int? amount;

  const DecrementLearnCount({this.amount});
}

class ResetLearnCount extends FlashcardEvent {}

class ValidateAnswer extends FlashcardEvent {
  final String userAnswer;

  const ValidateAnswer(this.userAnswer);

  @override
  List<Object?> get props => [userAnswer];
}

class SpeakFlashcardText extends FlashcardEvent {
  final String text;

  const SpeakFlashcardText(this.text);

  @override
  List<Object?> get props => [text];
}

class MarkAsKnown extends FlashcardEvent {
  final int? masteryLevel;

  const MarkAsKnown({this.masteryLevel});
}

class MarkAsUnknown extends FlashcardEvent {}

class RevealAnswer extends FlashcardEvent {
  const RevealAnswer();
}

class AutoFlipCard extends FlashcardEvent {
  final int newLearnCount;
  final Map<int, int> scores;
  final bool isCorrect;
  final String userAnswer;

  const AutoFlipCard({
    required this.newLearnCount,
    required this.scores,
    required this.isCorrect,
    required this.userAnswer,
  });
}
