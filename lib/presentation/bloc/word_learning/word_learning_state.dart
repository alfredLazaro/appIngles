import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/word_sumary.dart';

abstract class WordLearningState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WordLearningInitial extends WordLearningState {}

class WordLearningLoading extends WordLearningState {}

class WordsLoaded extends WordLearningState {
  final List<WordSummary> words;
  final int currentPage;

  WordsLoaded({required this.words, this.currentPage = 0});

  @override
  List<Object?> get props => [words, currentPage];
}

class WordSaved extends WordLearningState {
  final int wordId;
  final int imagesCount;

  WordSaved({required this.wordId, required this.imagesCount});

  @override
  List<Object?> get props => [wordId, imagesCount];
}

class WordLearningError extends WordLearningState {
  final String message;

  WordLearningError(this.message);

  @override
  List<Object?> get props => [message];
}

class DefinitionsLoaded extends WordLearningState {
  final List<Map<String, dynamic>> meanings;

  DefinitionsLoaded(this.meanings);

  @override
  List<Object?> get props => [meanings];
}

class ImagesLoaded extends WordLearningState {
  final List<Map<String, dynamic>> images;

  ImagesLoaded(this.images);

  @override
  List<Object?> get props => [images];
}
