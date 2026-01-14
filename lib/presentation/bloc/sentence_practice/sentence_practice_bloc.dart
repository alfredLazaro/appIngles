// sentence_practice_bloc.dart
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'sentence_practice_event.dart';
part 'sentence_practice_state.dart';

class SentencePracticeBloc
    extends Bloc<SentencePracticeEvent, SentencePracticeState> {
  SentencePracticeBloc() : super(SentencePracticeInitial()) {
    on<InitializeSentenceEvent>(_onInitializeSentence);
    on<AddWordToSentenceEvent>(_onAddWordToSentence);
    on<RemoveWordFromSentenceEvent>(_onRemoveWordFromSentence);
    on<CheckAnswerEvent>(_onCheckAnswer);
    on<ResetSentenceEvent>(_onResetSentence);
  }

  void _onInitializeSentence(
    InitializeSentenceEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    // Split sentence into words
    final words = event.originalSentence.split(' ');
    
    // Shuffle words
    final shuffledWords = List<String>.from(words)..shuffle(Random());
    
    // Initialize visibility (all visible)
    final wordVisibility = List<bool>.filled(shuffledWords.length, true);

    emit(SentencePracticeLoaded(
      sentenceId: event.sentenceId,
      originalSentence: event.originalSentence,
      shuffledWords: shuffledWords,
      wordVisibility: wordVisibility,
      userSentence: [],
    ));
  }

  void _onAddWordToSentence(
    AddWordToSentenceEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state is! SentencePracticeLoaded) return;

    final currentState = state as SentencePracticeLoaded;

    // Add word to user sentence
    final updatedUserSentence = List<String>.from(currentState.userSentence)
      ..add(event.word);

    // Hide the word from available words
    final updatedVisibility = List<bool>.from(currentState.wordVisibility);
    updatedVisibility[event.wordIndex] = false;

    emit(currentState.copyWith(
      userSentence: updatedUserSentence,
      wordVisibility: updatedVisibility,
      showResult: false, // Reset result when user makes changes
    ));
  }

  void _onRemoveWordFromSentence(
    RemoveWordFromSentenceEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state is! SentencePracticeLoaded) return;

    final currentState = state as SentencePracticeLoaded;

    // Get the word being removed
    final word = currentState.userSentence[event.userSentenceIndex];

    // Remove word from user sentence
    final updatedUserSentence = List<String>.from(currentState.userSentence)
      ..removeAt(event.userSentenceIndex);

    // Find the original index of this word and make it visible again
    final originalIndex = currentState.shuffledWords.indexOf(word);
    final updatedVisibility = List<bool>.from(currentState.wordVisibility);
    if (originalIndex != -1) {
      updatedVisibility[originalIndex] = true;
    }

    emit(currentState.copyWith(
      userSentence: updatedUserSentence,
      wordVisibility: updatedVisibility,
      showResult: false,
    ));
  }

  void _onCheckAnswer(
    CheckAnswerEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state is! SentencePracticeLoaded) return;

    final currentState = state as SentencePracticeLoaded;

    // Build user's sentence
    final userSentence = currentState.userSentence.join(' ');

    // Check if correct (case-insensitive, trimmed)
    final isCorrect = userSentence.trim().toLowerCase() ==
        currentState.originalSentence.trim().toLowerCase();

    emit(currentState.copyWith(
      isCorrect: isCorrect,
      showResult: true,
    ));
  }

  void _onResetSentence(
    ResetSentenceEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state is! SentencePracticeLoaded) return;

    final currentState = state as SentencePracticeLoaded;

    // Re-initialize with the same sentence
    add(InitializeSentenceEvent(
      sentenceId: currentState.sentenceId,
      originalSentence: currentState.originalSentence,
    ));
  }
}