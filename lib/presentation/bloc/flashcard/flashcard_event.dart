import 'package:equatable/equatable.dart';

abstract class FlashcardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlipFlashcard extends FlashcardEvent {}

class IncrementLearnCount extends FlashcardEvent {}

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
