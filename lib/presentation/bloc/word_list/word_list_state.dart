import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/word_with_image.dart';

abstract class WordListState extends Equatable {
  const WordListState();
}

class WordListInitial extends WordListState {
  const WordListInitial();

  @override
  List<Object?> get props => [];
}

class WordListLoading extends WordListState {
  const WordListLoading();

  @override
  List<Object?> get props => [];
}

class WordListLoaded extends WordListState {
  final List<WordWithImage> words;
  final int selectedCount;
  final String? filterQuery;
  final SortType sortType;

  const WordListLoaded({
    required this.words,
    this.selectedCount = 0,
    this.filterQuery,
    this.sortType = SortType.newest,
  });

  @override
  List<Object?> get props => [
        words,
        selectedCount,
        filterQuery,
        sortType,
      ];

  WordListLoaded copyWith({
    List<WordWithImage>? words,
    int? selectedCount,
    String? filterQuery,
    SortType? sortType,
  }) {
    return WordListLoaded(
      words: words ?? this.words,
      selectedCount: selectedCount ?? this.selectedCount,
      filterQuery: filterQuery ?? this.filterQuery,
      sortType: sortType ?? this.sortType,
    );
  }
}

enum SortType {
  newest('Más recientes'),
  oldest('Más antiguas'),
  alphabetical('A - Z'),
  learned('Mejor aprendidas');

  final String label;

  const SortType(this.label);
}

class WordListError extends WordListState {
  final String message;

  const WordListError(this.message);

  @override
  List<Object?> get props => [message];
}
