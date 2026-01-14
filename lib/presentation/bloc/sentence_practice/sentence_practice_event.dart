// sentence_practice_event.dart
part of 'sentence_practice_bloc.dart';

abstract class SentencePracticeEvent extends Equatable {
  const SentencePracticeEvent();
}

class InitializeSentenceEvent extends SentencePracticeEvent {
  final int sentenceId;
  final String originalSentence;

  const InitializeSentenceEvent({
    required this.sentenceId,
    required this.originalSentence,
  });

  @override
  List<Object> get props => [sentenceId, originalSentence];
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

class NavigateToSentenceEvent extends SentencePracticeEvent {
  final int index;

  const NavigateToSentenceEvent(this.index);

  @override
  List<Object> get props => [index];
}