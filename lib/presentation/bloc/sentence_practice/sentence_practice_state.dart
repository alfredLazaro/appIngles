// sentence_practice_state.dart
import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/sentence_model.dart';

abstract class SentencePracticeState extends Equatable {
  const SentencePracticeState();
}

class SentencePracticeInitial extends SentencePracticeState {
  @override
  List<Object> get props => [];
}

class SentencePracticeLoaded extends SentencePracticeState {
  final List<SentenceModel> sentences;
  final int currentIndex;
  final int sentenceId;
  final String originalSentence;
  final List<String> shuffledWords;
  final List<bool> wordVisibility;
  final List<String> userSentence;
  final bool isCorrect;
  final bool showResult;
  final int learnCount;
  final Map<int, int> scores;

  const SentencePracticeLoaded({
    required this.sentences,
    required this.currentIndex,
    required this.sentenceId,
    required this.originalSentence,
    required this.shuffledWords,
    required this.wordVisibility,
    required this.userSentence,
    required this.learnCount,
    required this.scores,
    this.isCorrect = false,
    this.showResult = false,
  });

  SentencePracticeLoaded copyWith({
    List<SentenceModel>? sentences,
    int? currentIndex,
    int? sentenceId,
    String? originalSentence,
    List<String>? shuffledWords,
    List<bool>? wordVisibility,
    List<String>? userSentence,
    bool? isCorrect,
    bool? showResult,
    int? learnCount,
    Map<int, int>? scores,
  }) {
    return SentencePracticeLoaded(
      sentences: sentences ?? this.sentences,
      currentIndex: currentIndex ?? this.currentIndex,
      sentenceId: sentenceId ?? this.sentenceId,
      originalSentence: originalSentence ?? this.originalSentence,
      shuffledWords: shuffledWords ?? this.shuffledWords,
      wordVisibility: wordVisibility ?? this.wordVisibility,
      userSentence: userSentence ?? this.userSentence,
      isCorrect: isCorrect ?? this.isCorrect,
      showResult: showResult ?? this.showResult,
      learnCount: learnCount ?? this.learnCount,
      scores: scores ?? this.scores,
    );
  }

  @override
  List<Object> get props => [
        sentences,
        currentIndex,
        sentenceId,
        originalSentence,
        shuffledWords,
        wordVisibility,
        userSentence,
        isCorrect,
        showResult,
        learnCount,
        scores,
      ];
}

class SentencePracticeCompleted extends SentencePracticeState {
  final Map<int, int> learnCountUpdates;
  final int totalItems;
  final int correctItems;

  const SentencePracticeCompleted({
    required this.learnCountUpdates,
    required this.totalItems,
    required this.correctItems,
  });

  @override
  List<Object> get props => [learnCountUpdates, totalItems, correctItems];
}