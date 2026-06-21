import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';

enum FlashcardMode { learn, test }

class FlashcardSession {
  final FlashcardWord word;
  final FlashcardMode mode;
  final int originalIndex;

  const FlashcardSession({
    required this.word,
    required this.mode,
    required this.originalIndex,
  });
}

abstract class FlashcardState extends Equatable {
  const FlashcardState();

  @override
  List<Object?> get props => [];
}

class FlashcardInitial extends FlashcardState {
  const FlashcardInitial();
}

class FlashcardLoaded extends FlashcardState {
  final List<FlashcardSession> sessions;
  final int currentIndex;
  final FlashcardWord word;
  final List<FlashcardImage> images;
  final FlashcardMode mode;
  final int originalIndex;
  final bool showFront;
  final int learnCount;
  final Map<int, int> scores;
  final bool? isAnswerCorrect;
  final bool isAnswerRevealed;
  final String userAnswer;

  const FlashcardLoaded({
    required this.sessions,
    required this.currentIndex,
    required this.word,
    required this.images,
    required this.mode,
    required this.originalIndex,
    this.showFront = true,
    this.learnCount = 0,
    required this.scores,
    this.isAnswerCorrect,
    this.isAnswerRevealed = false,
    this.userAnswer = '',
  });

  FlashcardLoaded copyWith({
    bool? showFront,
    int? learnCount,
    bool? isAnswerCorrect,
    Map<int, int>? scores,
    bool? isAnswerRevealed,
    String? userAnswer,
  }) {
    return FlashcardLoaded(
      sessions: sessions,
      currentIndex: currentIndex,
      word: word,
      images: images,
      mode: mode,
      originalIndex: originalIndex,
      showFront: showFront ?? this.showFront,
      learnCount: learnCount ?? this.learnCount,
      scores: scores ?? this.scores,
      isAnswerCorrect: isAnswerCorrect ?? this.isAnswerCorrect,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      userAnswer: userAnswer ?? this.userAnswer,
    );
  }

  @override
  List<Object?> get props => [
        sessions,
        currentIndex,
        word,
        images,
        mode,
        originalIndex,
        showFront,
        learnCount,
        scores,
        isAnswerCorrect,
        isAnswerRevealed,
        userAnswer,
      ];
}
