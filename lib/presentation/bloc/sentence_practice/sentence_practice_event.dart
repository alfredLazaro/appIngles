// sentence_practice_event.dart
import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/sentence_model.dart';

abstract class SentencePracticeEvent extends Equatable {
  const SentencePracticeEvent();
}

class InitializeSentencesEvent extends SentencePracticeEvent {
  final List<SentenceModel> sentences;

  const InitializeSentencesEvent({required this.sentences});

  @override
  List<Object> get props => [sentences];
}

class AddWordToSentenceEvent extends SentencePracticeEvent {
  final String word;
  final int wordIndex;

  const AddWordToSentenceEvent({
    required this.word,
    required this.wordIndex,
  });

  @override
  List<Object> get props => [word, wordIndex];
}

class RemoveWordFromSentenceEvent extends SentencePracticeEvent {
  final int userSentenceIndex;

  const RemoveWordFromSentenceEvent(this.userSentenceIndex);

  @override
  List<Object> get props => [userSentenceIndex];
}

class CheckAnswerEvent extends SentencePracticeEvent {
  const CheckAnswerEvent();

  @override
  List<Object> get props => [];
}

class ResetSentenceEvent extends SentencePracticeEvent {
  const ResetSentenceEvent();

  @override
  List<Object> get props => [];
}

class NextSentenceEvent extends SentencePracticeEvent {
  const NextSentenceEvent();

  @override
  List<Object> get props => [];
}

class PreviousSentenceEvent extends SentencePracticeEvent {
  const PreviousSentenceEvent();

  @override
  List<Object> get props => [];
}

class FinishSentenceEvent extends SentencePracticeEvent {
  const FinishSentenceEvent();

  @override
  List<Object> get props => [];
}