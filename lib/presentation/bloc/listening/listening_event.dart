import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';

abstract class ListeningEvent extends Equatable {
  const ListeningEvent();

  @override
  List<Object?> get props => [];
}

class InitializeListening extends ListeningEvent {
  final List<FlashcardWord> words;
  final int maxAudioPlays;

  const InitializeListening({required this.words, this.maxAudioPlays = 0});

  @override
  List<Object?> get props => [words, maxAudioPlays];
}

class PlayCurrentWordAudioListening extends ListeningEvent {
  const PlayCurrentWordAudioListening();
}

class SubmitListeningAnswer extends ListeningEvent {
  final String answer;

  const SubmitListeningAnswer(this.answer);

  @override
  List<Object?> get props => [answer];
}

class NextListeningWord extends ListeningEvent {
  const NextListeningWord();
}

class PreviousListeningWord extends ListeningEvent {
  const PreviousListeningWord();
}

class SkipListeningWord extends ListeningEvent {
  const SkipListeningWord();
}

class FinishListening extends ListeningEvent {
  const FinishListening();
}
