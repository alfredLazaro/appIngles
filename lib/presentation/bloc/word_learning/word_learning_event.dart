import 'package:equatable/equatable.dart';

abstract class WordLearningEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRecentWordsEvent extends WordLearningEvent {}

class SearchWordDefinitionEvent extends WordLearningEvent {
  final String word;

  SearchWordDefinitionEvent(this.word);

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
  final List<Map<String, dynamic>> selectedImages;

  SaveNewWordEvent({
    required this.wordData,
    required this.selectedImages,
  });

  @override
  List<Object?> get props => [wordData, selectedImages];
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
