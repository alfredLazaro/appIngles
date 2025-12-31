import 'package:equatable/equatable.dart';

abstract class FlashcardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlipFlashcard extends FlashcardEvent {}

class IncrementLearnCount extends FlashcardEvent {
  final int? amount; // Optional: allow custom increment amount
  
  IncrementLearnCount({this.amount});
}

class DecrementLearnCount extends FlashcardEvent {
  final int? amount; // Optional: allow custom decrement amount
  
  DecrementLearnCount({this.amount});
}

class ResetLearnCount extends FlashcardEvent {}

class ValidateAnswer extends FlashcardEvent {
  final String userAnswer;

  ValidateAnswer(this.userAnswer);

  @override
  List<Object?> get props => [userAnswer];
}

class SpeakFlashcardText extends FlashcardEvent {
  final String text;

  SpeakFlashcardText(this.text);

  @override
  List<Object?> get props => [text];
}
class MarkAsKnown extends FlashcardEvent {
  final int? masteryLevel; // Optional: custom mastery level
  
  MarkAsKnown({this.masteryLevel});
}

class MarkAsUnknown extends FlashcardEvent {}