import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/word_filter.dart';

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
  final int word_id;

  const DeleteWordEvent(this.word_id);

  @override
  List<Object?> get props => [word_id];
}

class ToggleWordSelectionEvent extends WordListEvent {
  final int word_id;

  const ToggleWordSelectionEvent(this.word_id);

  @override
  List<Object?> get props => [word_id];
}

class FilterWordsEvent extends WordListEvent {
  final String query;

  const FilterWordsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSelectionEvent extends WordListEvent {
  const ClearSelectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadWordStatsEvent extends WordListEvent {
  const LoadWordStatsEvent();

  @override
  List<Object?> get props => [];
}

class SetFilterEvent extends WordListEvent {
  final WordFilterMode mode;

  const SetFilterEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}
