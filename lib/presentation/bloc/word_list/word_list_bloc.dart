import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/entities/word_filter.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/usecases/word/get_word_statistics.dart';

import 'word_list_event.dart';
import 'word_list_state.dart';

class WordListBloc extends Bloc<WordListEvent, WordListState> {
  final WordRepository _wordRepository;
  final GetWordStatisticsUseCase _getWordStatisticsUseCase;
  final Set<int> _selectedWordIds = {};
  final int _pageSize = 20;

  WordListBloc({
    required WordRepository wordRepository,
    required GetWordStatisticsUseCase getWordStatisticsUseCase,
  })  : _wordRepository = wordRepository,
        _getWordStatisticsUseCase = getWordStatisticsUseCase,
        super(const WordListInitial()) {
    on<LoadWordsEvent>(_onLoadWords);
    on<LoadMoreWordsEvent>(_onLoadMoreWords);
    on<RefreshWordsEvent>(_onRefreshWords);
    on<DeleteWordEvent>(_onDeleteWord);
    on<ToggleWordSelectionEvent>(_onToggleWordSelection);
    on<FilterWordsEvent>(_onFilterWords);
    on<SetFilterEvent>(_onSetFilter);
    on<LoadWordStatsEvent>(_onLoadWordStats);
    on<ClearSelectionEvent>(_onClearSelection);
  }

  Future<void> _onLoadWords(
    LoadWordsEvent event,
    Emitter<WordListState> emit,
  ) async {
    emit(const WordListLoading());

    try {
      final filterMode =
          state is WordListLoaded ? (state as WordListLoaded).filterMode : null;
      final result = await _wordRepository.getWordsWithImagesPaginated(
        page: 1,
        pageSize: _pageSize,
        searchQuery: event.searchQuery,
        filterMode: filterMode,
      );
      final stats = await _getWordStatisticsUseCase();
      emit(WordListLoaded(
        words: result.items,
        currentPage: 1,
        hasMorePages: result.hasNextPage,
        isLoadingMore: false,
        filterQuery: event.searchQuery,
        filterMode: filterMode ?? WordFilterMode.all,
        stats: stats,
      ));
    } catch (e) {
      emit(WordListError(e.toString()));
    }
  }

  Future<void> _onLoadMoreWords(
    LoadMoreWordsEvent event,
    Emitter<WordListState> emit,
  ) async {
    if (state is! WordListLoaded) return;

    final currentState = state as WordListLoaded;

    // Don't load if already loading or no more pages
    if (currentState.isLoadingMore || !currentState.hasMorePages) return;

    // Emit loading more state
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final result = await _wordRepository.getWordsWithImagesPaginated(
        page: nextPage,
        pageSize: _pageSize,
        searchQuery: currentState.filterQuery,
        filterMode: currentState.filterMode,
      );

      // Append new words to existing list
      final updatedWords = [...currentState.words, ...result.items];

      emit(WordListLoaded(
        words: updatedWords,
        currentPage: nextPage,
        hasMorePages: result.hasNextPage,
        isLoadingMore: false,
        filterQuery: currentState.filterQuery,
        filterMode: currentState.filterMode,
        selectedCount: currentState.selectedCount,
        stats: currentState.stats,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isLoadingMore: false,
        errorMessage: 'Error al cargar más palabras: $e',
      ));
    }
  }

  Future<void> _onRefreshWords(
    RefreshWordsEvent event,
    Emitter<WordListState> emit,
  ) async {
    // Get current filter query and mode if exists
    String? searchQuery;
    WordFilterMode? filterMode;
    if (state is WordListLoaded) {
      final currentState = state as WordListLoaded;
      searchQuery = currentState.filterQuery;
      filterMode = currentState.filterMode;
    }

    try {
      final result = await _wordRepository.getWordsWithImagesPaginated(
        page: 1,
        pageSize: _pageSize,
        searchQuery: searchQuery,
        filterMode: filterMode,
      );
      final stats = await _getWordStatisticsUseCase();
      if (state is WordListLoaded) {
        final currentState = state as WordListLoaded;
        emit(currentState.copyWith(
          words: result.items,
          currentPage: 1,
          hasMorePages: result.hasNextPage,
          stats: stats,
          clearError: true,
        ));
      } else {
        emit(WordListLoaded(
          words: result.items,
          currentPage: 1,
          hasMorePages: result.hasNextPage,
          stats: stats,
        ));
      }
    } catch (e) {
      if (state is WordListLoaded) {
        emit((state as WordListLoaded).copyWith(
          errorMessage: 'Error al actualizar: $e',
        ));
      } else {
        emit(WordListError('Error al actualizar: $e'));
      }
    }
  }

  Future<void> _onDeleteWord(
    DeleteWordEvent event,
    Emitter<WordListState> emit,
  ) async {
    try {
      await _wordRepository.deleteWord(event.wordId);

      // Remove from selection if selected
      _selectedWordIds.remove(event.wordId);

      // Refresh the list
      add(const RefreshWordsEvent());
    } catch (e) {
      emit(WordListError('Error al eliminar palabra: $e'));
    }
  }

  void _onToggleWordSelection(
    ToggleWordSelectionEvent event,
    Emitter<WordListState> emit,
  ) {
    if (state is! WordListLoaded) return;

    final currentState = state as WordListLoaded;

    if (_selectedWordIds.contains(event.wordId)) {
      _selectedWordIds.remove(event.wordId);
    } else {
      _selectedWordIds.add(event.wordId);
    }

    emit(currentState.copyWith(selectedCount: _selectedWordIds.length));
  }

  void _onFilterWords(
    FilterWordsEvent event,
    Emitter<WordListState> emit,
  ) async {
    final previousLoadedState =
        state is WordListLoaded ? state as WordListLoaded : null;

    final filterMode = previousLoadedState?.filterMode;

    emit(const WordListLoading());

    try {
      final result = await _wordRepository.getWordsWithImagesPaginated(
        page: 1,
        pageSize: _pageSize,
        searchQuery: event.query,
        filterMode: filterMode,
      );
      final stats = await _getWordStatisticsUseCase();

      emit(WordListLoaded(
        words: result.items,
        currentPage: 1,
        hasMorePages: result.hasNextPage,
        filterQuery: event.query,
        filterMode: filterMode ?? WordFilterMode.all,
        stats: stats,
      ));
    } catch (e) {
      if (previousLoadedState != null) {
        emit(previousLoadedState.copyWith(
          errorMessage: 'Error al filtrar: $e',
        ));
      } else {
        emit(WordListError('Error al filtrar: $e'));
      }
    }
  }

  void _onSetFilter(
    SetFilterEvent event,
    Emitter<WordListState> emit,
  ) async {
    final previousLoadedState =
        state is WordListLoaded ? state as WordListLoaded : null;

    emit(const WordListLoading());

    try {
      final searchQuery = previousLoadedState?.filterQuery;
      final result = await _wordRepository.getWordsWithImagesPaginated(
        page: 1,
        pageSize: _pageSize,
        searchQuery: searchQuery,
        filterMode: event.mode,
      );
      final stats = await _getWordStatisticsUseCase();

      emit(WordListLoaded(
        words: result.items,
        currentPage: 1,
        hasMorePages: result.hasNextPage,
        filterQuery: searchQuery,
        filterMode: event.mode,
        stats: stats,
      ));
    } catch (e) {
      if (previousLoadedState != null) {
        emit(previousLoadedState.copyWith(
          errorMessage: 'Error al filtrar: $e',
        ));
      } else {
        emit(WordListError('Error al filtrar: $e'));
      }
    }
  }

  Future<void> _onLoadWordStats(
    LoadWordStatsEvent event,
    Emitter<WordListState> emit,
  ) async {
    if (state is! WordListLoaded) return;

    final currentState = state as WordListLoaded;

    try {
      final stats = await _getWordStatisticsUseCase();
      emit(currentState.copyWith(stats: stats));
    } catch (e) {
      // Keep current state if stats loading fails
    }
  }
  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<WordListState> emit,
  ) {
    _selectedWordIds.clear();

    if (state is WordListLoaded) {
      final currentState = state as WordListLoaded;
      emit(currentState.copyWith(selectedCount: 0));
    }
  }
}
