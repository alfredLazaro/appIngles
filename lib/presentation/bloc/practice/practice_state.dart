import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';

abstract class PracticeState extends Equatable {
  const PracticeState();
}

class PracticeInitial extends PracticeState {
  @override
  List<Object> get props => [];
}

class PracticeLoading extends PracticeState {
  @override
  List<Object> get props => [];
}

class PracticeDataLoaded extends PracticeState {
  final int totalCount;

  const PracticeDataLoaded(this.totalCount);

  @override
  List<Object> get props => [totalCount];
}

class PracticeReady extends PracticeState {
  final List<FlashcardWord> words;
  final Map<int, List<FlashcardImage>> imagesMap;

  const PracticeReady(this.words, this.imagesMap);

  @override
  List<Object> get props => [words, imagesMap];
}

class PracticeError extends PracticeState {
  final String message;

  const PracticeError(this.message);

  @override
  List<Object> get props => [message];
}
