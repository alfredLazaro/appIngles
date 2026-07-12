import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';

abstract class SpellingState extends Equatable {
  const SpellingState();

  @override
  List<Object?> get props => [];
}

class SpellingInitial extends SpellingState {
  const SpellingInitial();
}

class SpellingLoaded extends SpellingState {
  final List<FlashcardWord> words;
  final int currentIndex;
  final FlashcardWord currentWord;
  final String userAnswer;
  final bool? isCorrect;
  final int learnCount;
  final Map<int, int> scores;
  final int maxAudioPlays;
  final int audioPlayedCount;
  final bool hasSubmitted;

  const SpellingLoaded({
    required this.words,
    required this.currentIndex,
    required this.currentWord,
    required this.userAnswer,
    this.isCorrect,
    required this.learnCount,
    required this.scores,
    required this.maxAudioPlays,
    required this.audioPlayedCount,
    this.hasSubmitted = false,
  });

  SpellingLoaded copyWith({
    List<FlashcardWord>? words,
    int? currentIndex,
    FlashcardWord? currentWord,
    String? userAnswer,
    bool? isCorrect,
    int? learnCount,
    Map<int, int>? scores,
    int? maxAudioPlays,
    int? audioPlayedCount,
    bool? hasSubmitted,
    bool clearIsCorrect = false,
  }) {
    return SpellingLoaded(
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      currentWord: currentWord ?? this.currentWord,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: clearIsCorrect ? null : (isCorrect ?? this.isCorrect),
      learnCount: learnCount ?? this.learnCount,
      scores: scores ?? this.scores,
      maxAudioPlays: maxAudioPlays ?? this.maxAudioPlays,
      audioPlayedCount: audioPlayedCount ?? this.audioPlayedCount,
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
    );
  }

  @override
  List<Object?> get props => [
        words,
        currentIndex,
        currentWord,
        userAnswer,
        isCorrect,
        learnCount,
        scores,
        maxAudioPlays,
        audioPlayedCount,
        hasSubmitted,
      ];
}

class SpellingCompleted extends SpellingState {
  final Map<int, int> learnCountUpdates;
  final int totalItems;
  final int correctItems;

  const SpellingCompleted({
    required this.learnCountUpdates,
    required this.totalItems,
    required this.correctItems,
  });

  @override
  List<Object?> get props => [learnCountUpdates, totalItems, correctItems];
}
