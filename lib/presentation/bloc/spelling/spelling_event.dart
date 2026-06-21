import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';

abstract class SpellingEvent extends Equatable {
  const SpellingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSpelling extends SpellingEvent {
  final List<FlashcardWord> words;
  final int maxAudioPlays;

  const InitializeSpelling({required this.words, this.maxAudioPlays = 0});

  @override
  List<Object?> get props => [words, maxAudioPlays];
}

class PlayCurrentWordAudio extends SpellingEvent {
  const PlayCurrentWordAudio();
}

class SubmitSpellingAnswer extends SpellingEvent {
  final String answer;

  const SubmitSpellingAnswer(this.answer);

  @override
  List<Object?> get props => [answer];
}

class NextSpellingWord extends SpellingEvent {
  const NextSpellingWord();
}

class PreviousSpellingWord extends SpellingEvent {
  const PreviousSpellingWord();
}

class SkipSpellingWord extends SpellingEvent {
  const SkipSpellingWord();
}

class FinishSpelling extends SpellingEvent {
  const FinishSpelling();
}
