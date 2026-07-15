import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/domain/entities/word_insertion.dart';

abstract class WordLearningEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRecentWordsEvent extends WordLearningEvent {
  final int? limit;
  LoadRecentWordsEvent({this.limit});
}

class SearchWordEvent extends WordLearningEvent {
  final String word;

  SearchWordEvent(this.word);

  @override
  List<Object?> get props => [word];
}

class SearchWordImagesEvent extends WordLearningEvent {
  final String query;

  SearchWordImagesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SaveNewWordEvent extends WordLearningEvent {
  final Map<String, dynamic> wordData;
  final List<ImageSearchResult> selectedImages;
  final Map<String, dynamic>? translation;
  final List<String> selectedAlternatives;

  SaveNewWordEvent({
    required this.wordData,
    required this.selectedImages,
    this.translation,
    this.selectedAlternatives = const [],
  });

  @override
  List<Object?> get props => [wordData, selectedImages, translation, selectedAlternatives];
}

class UpdateWordSentenceEvent extends WordLearningEvent {
  final int wordId;
  final String newSentence;

  UpdateWordSentenceEvent({
    required this.wordId,
    required this.newSentence,
  });

  @override
  List<Object?> get props => [wordId, newSentence];
}

class DeleteWordEvent extends WordLearningEvent {
  final int wordId;

  DeleteWordEvent(this.wordId);

  @override
  List<Object?> get props => [wordId];
}

class ChangePageEvent extends WordLearningEvent {
  final int page;

  ChangePageEvent(this.page);

  @override
  List<Object?> get props => [page];
}

class InsertLotWordsEvent extends WordLearningEvent {
  final List<WordInsertion> words;
  final VoidCallback? onCompleted;

  InsertLotWordsEvent(this.words, {this.onCompleted});
}

// word_learning_event.dart
class FetchWordsEvent extends WordLearningEvent {
  final int limit;

  FetchWordsEvent(this.limit);

  @override
  List<Object?> get props => [limit];
}
