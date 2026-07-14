import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';

abstract class ListeningState extends Equatable {
  const ListeningState();

  @override
  List<Object?> get props => [];
}

class ListeningInitial extends ListeningState {
  const ListeningInitial();
}

class ListeningLoaded extends ListeningState {
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

  const ListeningLoaded({
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

  ListeningLoaded copyWith({
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
    return ListeningLoaded(
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

class ListeningCompleted extends ListeningState {
  final Map<int, int> learnCountUpdates;
  final int totalItems;
  final int correctItems;

  const ListeningCompleted({
    required this.learnCountUpdates,
    required this.totalItems,
    required this.correctItems,
  });

  @override
  List<Object?> get props => [learnCountUpdates, totalItems, correctItems];
}
