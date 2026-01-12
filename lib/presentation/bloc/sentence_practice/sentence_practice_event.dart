// lib/presentation/bloc/sentence_practice/sentence_practice_event.dart

abstract class SentencePracticeEvent {}

/// Load sentences for practice
class LoadSentences extends SentencePracticeEvent {
  final int count;
  LoadSentences(this.count);
}

/// Check if user's answer is correct
class CheckAnswer extends SentencePracticeEvent {
  final int sentenceId;
  final String userAnswer;
  
  CheckAnswer({
    required this.sentenceId,
    required this.userAnswer,
  });
}

/// Reset current sentence
class ResetSentence extends SentencePracticeEvent {
  final int sentenceId;
  ResetSentence(this.sentenceId);
}

/// Speak sentence text
class SpeakSentence extends SentencePracticeEvent {
  final String text;
  SpeakSentence(this.text);
}

/// Navigate to next sentence
class NextSentence extends SentencePracticeEvent {}

/// Navigate to previous sentence
class PreviousSentence extends SentencePracticeEvent {}

/// Jump to specific sentence
class JumpToSentence extends SentencePracticeEvent {
  final int index;
  JumpToSentence(this.index);
}