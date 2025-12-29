import 'package:bloc/bloc.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/repositories/image_repository.dart';

import 'word_list_event.dart';
import 'word_list_state.dart';

class WordListBloc extends Bloc<WordListEvent, WordListState> {
  final WordRepository _wordRepository;
  final ImageRepository _imageRepository;
  final Set<int> _selectedWordIds = {};
  final int _pageSize = 20;
  WordListBloc({
    required WordRepository wordRepository,
    required ImageRepository imageRepository,
  })  : _wordRepository = wordRepository,
        _imageRepository = imageRepository,
        super(const WordListInitial()) {
    on<LoadWordsEvent>(_onLoadWords);
    on<RefreshWordsEvent>(_onRefreshWords);
    on<DeleteWordEvent>(_onDeleteWord);
    on<ToggleWordSelectionEvent>(_onToggleWordSelection);
    on<FilterWordsEvent>(_onFilterWords);
    on<SortWordsEvent>(_onSortWords);
    on<ClearSelectionEvent>(_onClearSelection);
  }

  Future<void> _onLoadWords(
    LoadWordsEvent event,
    Emitter<WordListState> emit,
  ) async {
    emit(const WordListLoading());

    try {
      final words = await _wordRepository.getWordsWithImagesPaginated(
        page: 1,
        pageSize: _pageSize,
      );
      emit(WordListLoaded(words: words.items));
    } catch (e) {
      emit(WordListError(e.toString()));
    }
  }

  Future<void> _onRefreshWords(
    RefreshWordsEvent event,
    Emitter<WordListState> emit,
  ) async {
    try {
      final words = await _wordRepository.getAllWordsWithImages();

      if (state is WordListLoaded) {
        final currentState = state as WordListLoaded;
        emit(currentState.copyWith(words: words));
      } else {
        emit(WordListLoaded(words: words));
      }
    } catch (e) {
      // Mantener estado anterior en caso de error
      if (state is WordListLoaded) {
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
      //await _imageRepository.deleteImagesByWordId(event.wordId);

      // Actualizar lista
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
  ) {
    if (state is! WordListLoaded) return;

    final currentState = state as WordListLoaded;
    emit(currentState.copyWith(filterQuery: event.query));
  }

  void _onSortWords(
    SortWordsEvent event,
    Emitter<WordListState> emit,
  ) {
    if (state is! WordListLoaded) return;

    final currentState = state as WordListLoaded;
    emit(currentState.copyWith(sortType: event.sortType));
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
