import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';

abstract class FlashcardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FlashcardInitial extends FlashcardState {}

class FlashcardLoaded extends FlashcardState {
  final FlashcardWord word;
  final List<FlashcardImage> images;
  final bool showFront;
  final int learnCount;

  FlashcardLoaded({
    required this.word,
    required this.images,
    this.showFront = true,
    this.learnCount = 0,
  });

  FlashcardLoaded copyWith({
    FlashcardWord? word,
    List<FlashcardImage>? images,
    bool? showFront,
    int? learnCount,
  }) {
    return FlashcardLoaded(
      word: word ?? this.word,
      images: images ?? this.images,
      showFront: showFront ?? this.showFront,
      learnCount: learnCount ?? this.learnCount,
    );
  }

  @override
  List<Object?> get props => [word, images, showFront, learnCount];
}

class FlashcardAnswerValidated extends FlashcardState {
  final bool isCorrect;

  FlashcardAnswerValidated(this.isCorrect);

  @override
  List<Object?> get props => [isCorrect];
}
