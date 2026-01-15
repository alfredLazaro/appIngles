import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/word_image.dart';
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
  final int currentPage;
  final bool hasMorePages;
  final bool isLoadingMore;
  final String? filterQuery;
  final int selectedCount;
  final String? sortType;

  const WordListLoaded({
    required this.words,
    this.currentPage = 1,
    this.hasMorePages = false,
    this.isLoadingMore = false,
    this.filterQuery,
    this.selectedCount = 0,
    this.sortType,
  });

  WordListLoaded copyWith({
    List<WordWithImage>? words,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
    String? filterQuery,
    int? selectedCount,
    String? sortType,
  }) {
    return WordListLoaded(
      words: words ?? this.words,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filterQuery: filterQuery ?? this.filterQuery,
      selectedCount: selectedCount ?? this.selectedCount,
      sortType: sortType ?? this.sortType,
    );
  }

  @override
  List<Object?> get props => [
        words,
        currentPage,
        hasMorePages,
        isLoadingMore,
        filterQuery,
        selectedCount,
        sortType,
      ];
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

class WordLoaded extends WordListState {
  final FlashcardWord w;
  final List<WordImage> images;
  const WordLoaded(this.w, this.images);
  @override
  List<Object?> get props => [w, images];
}
