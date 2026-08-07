// sentence_practice_state.dart
import 'package:equatable/equatable.dart';

abstract class SentencePracticeState extends Equatable {
  const SentencePracticeState();
}

class SentencePracticeInitial extends SentencePracticeState {
  @override
  List<Object> get props => [];
}

class SentencePracticeLoaded extends SentencePracticeState {
  final int word_id;
  final String originalSentence;
  final List<String> shuffledWords;
  final List<bool> wordVisibility;
  final List<String> userSentence;
  final bool isCorrect;
  final bool showResult;

  const SentencePracticeLoaded({
    required this.word_id,
    required this.originalSentence,
    required this.shuffledWords,
    required this.wordVisibility,
    required this.userSentence,
    this.isCorrect = false,
    this.showResult = false,
  });

  SentencePracticeLoaded copyWith({
    int? word_id,
    String? originalSentence,
    List<String>? shuffledWords,
    List<bool>? wordVisibility,
    List<String>? userSentence,
    bool? isCorrect,
    bool? showResult,
  }) {
    return SentencePracticeLoaded(
      word_id: word_id ?? this.word_id,
      originalSentence: originalSentence ?? this.originalSentence,
      shuffledWords: shuffledWords ?? this.shuffledWords,
      wordVisibility: wordVisibility ?? this.wordVisibility,
      userSentence: userSentence ?? this.userSentence,
      isCorrect: isCorrect ?? this.isCorrect,
      showResult: showResult ?? this.showResult,
    );
  }

  @override
  List<Object> get props => [
        word_id,
        originalSentence,
        shuffledWords,
        wordVisibility,
        userSentence,
        isCorrect,
        showResult,
      ];
}
