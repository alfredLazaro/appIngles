// sentence_practice_bloc.dart
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:first_app/domain/entities/sentence_model.dart';

import 'sentence_practice_event.dart';
import 'sentence_practice_state.dart';

class SentencePracticeBloc
    extends Bloc<SentencePracticeEvent, SentencePracticeState> {
  static const int _correctPoints = 6;
  static const int _wrongPoints = 2;

  late List<SentenceModel> _sentences;
  final Map<int, int> _scores = {};
  final Map<int, bool> _lastResult = {};
  int _currentIndex = 0;

  SentencePracticeBloc() : super(SentencePracticeInitial()) {
    on<InitializeSentencesEvent>(_onInitializeSentences);
    on<AddWordToSentenceEvent>(_onAddWordToSentence);
    on<RemoveWordFromSentenceEvent>(_onRemoveWordFromSentence);
    on<CheckAnswerEvent>(_onCheckAnswer);
    on<ResetSentenceEvent>(_onResetSentence);
    on<NextSentenceEvent>(_onNextSentence);
    on<PreviousSentenceEvent>(_onPreviousSentence);
    on<FinishSentenceEvent>(_onFinishSentence);
  }

  List<String> _shuffleWords(String sentence) =>
      (sentence.split(' ')..shuffle(Random()));

  SentencePracticeLoaded _buildLoadedState(int index) {
    final sentence = _sentences[index];
    return SentencePracticeLoaded(
      sentences: _sentences,
      currentIndex: index,
      sentenceId: sentence.id,
      originalSentence: sentence.sentence,
      shuffledWords: _shuffleWords(sentence.sentence),
      wordVisibility: List<bool>.filled(
        sentence.sentence.split(' ').length,
        true,
      ),
      userSentence: const [],
      learnCount: _scores[sentence.id] ?? sentence.learnCount,
      scores: Map.from(_scores),
    );
  }

  void _onInitializeSentences(
    InitializeSentencesEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    _sentences = event.sentences;
    _scores.clear();
    _lastResult.clear();
    _currentIndex = 0;

    for (final s in _sentences) {
      _scores[s.id] = s.learnCount;
    }

    if (_sentences.isEmpty) {
      emit(const SentencePracticeCompleted(
        learnCountUpdates: {},
        totalItems: 0,
        correctItems: 0,
      ));
      return;
    }

    emit(_buildLoadedState(0));
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

  int _applyScore(int sentenceId, bool isCorrect) {
    final current = _scores[sentenceId] ?? 0;
    final updated = isCorrect
        ? current + _correctPoints
        : max(0, current - _wrongPoints);
    _scores[sentenceId] = updated;
    return updated;
  }

  void _onCheckAnswer(
    CheckAnswerEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state is! SentencePracticeLoaded) return;

    final currentState = state as SentencePracticeLoaded;
    if (currentState.showResult) return;

    // Build user's sentence
    final userSentence = currentState.userSentence.join(' ');

    // Check if correct (case-insensitive, trimmed)
    final isCorrect = userSentence.trim().toLowerCase() ==
        currentState.originalSentence.trim().toLowerCase();

    _lastResult[currentState.sentenceId] = isCorrect;
    final newLearnCount = _applyScore(currentState.sentenceId, isCorrect);

    emit(currentState.copyWith(
      isCorrect: isCorrect,
      showResult: true,
      learnCount: newLearnCount,
      scores: Map.from(_scores),
    ));
  }

  void _onResetSentence(
    ResetSentenceEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state is! SentencePracticeLoaded) return;

    final currentState = state as SentencePracticeLoaded;

    emit(currentState.copyWith(
      shuffledWords: _shuffleWords(currentState.originalSentence),
      wordVisibility: List<bool>.filled(
        currentState.originalSentence.split(' ').length,
        true,
      ),
      userSentence: [],
      isCorrect: false,
      showResult: false,
    ));
  }

  void _onNextSentence(
    NextSentenceEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state is! SentencePracticeLoaded) return;

    if (_currentIndex >= _sentences.length - 1) {
      _emitCompleted(emit);
      return;
    }

    _currentIndex++;
    emit(_buildLoadedState(_currentIndex));
  }

  void _onPreviousSentence(
    PreviousSentenceEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state is! SentencePracticeLoaded) return;

    if (_currentIndex <= 0) return;

    _currentIndex--;
    emit(_buildLoadedState(_currentIndex));
  }

  void _onFinishSentence(
    FinishSentenceEvent event,
    Emitter<SentencePracticeState> emit,
  ) {
    if (state is! SentencePracticeLoaded) return;

    _emitCompleted(emit);
  }

  void _emitCompleted(Emitter<SentencePracticeState> emit) {
    final correctItems = _lastResult.values.where((r) => r).length;
    emit(SentencePracticeCompleted(
      learnCountUpdates: Map.from(_scores),
      totalItems: _sentences.length,
      correctItems: correctItems,
    ));
  }
}