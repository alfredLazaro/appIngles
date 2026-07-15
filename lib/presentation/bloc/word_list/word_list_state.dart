import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/word_filter.dart';
import 'package:first_app/domain/entities/word_stats.dart';
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
  final WordFilterMode filterMode;
  final int selectedCount;
  final WordStats? stats;
  final String? errorMessage;
  const WordListLoaded({
    required this.words,
    this.currentPage = 1,
    this.hasMorePages = false,
    this.isLoadingMore = false,
    this.filterQuery,
    this.filterMode = WordFilterMode.all,
    this.selectedCount = 0,
    this.stats,
    this.errorMessage,
  });

  WordListLoaded copyWith({
    List<WordWithImage>? words,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
    String? filterQuery,
    WordFilterMode? filterMode,
    int? selectedCount,
    WordStats? stats,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WordListLoaded(
      words: words ?? this.words,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filterQuery: filterQuery ?? this.filterQuery,
      filterMode: filterMode ?? this.filterMode,
      selectedCount: selectedCount ?? this.selectedCount,
      stats: stats ?? this.stats,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        words,
        currentPage,
        hasMorePages,
        isLoadingMore,
        filterQuery,
        filterMode,
        selectedCount,
        stats,
        errorMessage,
      ];
}

class WordListError extends WordListState {
  final String message;

  const WordListError(this.message);

  @override
  List<Object?> get props => [message];
}
