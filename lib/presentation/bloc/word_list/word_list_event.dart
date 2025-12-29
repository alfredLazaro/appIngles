import 'package:equatable/equatable.dart';
import 'word_list_state.dart'; // Importar para usar SortType

abstract class WordListEvent extends Equatable {
  const WordListEvent();
}

class LoadWordsEvent extends WordListEvent {
  final String? searchQuery;

  const LoadWordsEvent({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class LoadMoreWordsEvent extends WordListEvent {
  const LoadMoreWordsEvent();

  @override
  List<Object?> get props => [];
}

class RefreshWordsEvent extends WordListEvent {
  const RefreshWordsEvent();

  @override
  List<Object?> get props => [];
}

class DeleteWordEvent extends WordListEvent {
  final int wordId;

  const DeleteWordEvent(this.wordId);

  @override
  List<Object?> get props => [wordId];
}

class ToggleWordSelectionEvent extends WordListEvent {
  final int wordId;

  const ToggleWordSelectionEvent(this.wordId);

  @override
  List<Object?> get props => [wordId];
}

class FilterWordsEvent extends WordListEvent {
  final String query;

  const FilterWordsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SortWordsEvent extends WordListEvent {
  final SortType sortType;

  const SortWordsEvent(this.sortType);

  @override
  List<Object?> get props => [sortType];
}

class ClearSelectionEvent extends WordListEvent {
  const ClearSelectionEvent();

  @override
  List<Object?> get props => [];
}
