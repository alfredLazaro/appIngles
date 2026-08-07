import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/domain/entities/insertion_result.dart';
import 'package:first_app/domain/entities/word.dart';
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
  final int word_id;
  final int imagesCount;

  WordSaved({required this.word_id, required this.imagesCount});

  @override
  List<Object?> get props => [word_id, imagesCount];
}

class WordLearningError extends WordLearningState {
  final String message;

  WordLearningError(this.message);

  @override
  List<Object?> get props => [message];
}

class WordDataLoaded extends WordLearningState {
  final List<Map<String, dynamic>> meanings;
  final List<ImageSearchResult> images;
  final Map<String, dynamic>? translation;
  final Map<String, String>? alternativeTranslations;

  WordDataLoaded({
    required this.meanings,
    required this.images,
    this.translation,
    this.alternativeTranslations,
  });

  @override
  List<Object?> get props => [meanings, images, translation, alternativeTranslations];
}

class ImagesLoaded extends WordLearningState {
  final List<ImageSearchResult> images;

  ImagesLoaded({required this.images});

  @override
  List<Object?> get props => [images];
}

class LotWordsInserted extends WordLearningState {
  final List<InsertionResult> results;

  LotWordsInserted({required this.results});
}

// word_learning_state.dart
class WordsFetched extends WordLearningState {
  final List<Word> words;

  WordsFetched(this.words);

  @override
  List<Object?> get props => [words];
}
