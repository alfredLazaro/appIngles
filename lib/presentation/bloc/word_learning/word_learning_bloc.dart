import 'dart:convert';
import 'dart:io';

import 'package:first_app/domain/usecases/word/get_recent_words_summary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/usecases/word/save_word.dart';
import 'package:first_app/domain/usecases/word/delete_word.dart';
import 'package:first_app/domain/usecases/word/update_sentence.dart';
import 'package:first_app/domain/usecases/word/search_word_definition.dart';
import 'package:first_app/domain/usecases/image/search_images.dart';
import 'package:first_app/domain/usecases/image/save_word_images.dart';
import 'package:first_app/domain/usecases/word/insert_lot_words.dart';
import 'word_learning_event.dart';
import 'word_learning_state.dart';

class WordLearningBloc extends Bloc<WordLearningEvent, WordLearningState> {
  // Variables con sufijo "UseCase"
  final GetRecentWordsSummaryUseCase _getRecentWords;
  final SaveWordUseCase _saveWord;
  final DeleteWordUseCase _deleteWord;
  final UpdateSentenceUseCase _updateSentence;
  final SearchWordDefinitionUseCase _searchWordDefinition;
  final SearchImagesUseCase _searchImages;
  final SaveWordImagesUseCase _saveWordImages;
  final InsertLotWordsUseCase _saveLotWords;

  WordLearningBloc({
    required GetRecentWordsSummaryUseCase getRecentWords,
    required SaveWordUseCase saveWord,
    required DeleteWordUseCase deleteWord,
    required UpdateSentenceUseCase updateSentence,
    required SearchWordDefinitionUseCase searchWordDefinition,
    required SearchImagesUseCase searchImages,
    required SaveWordImagesUseCase saveWordImages,
    required InsertLotWordsUseCase saveLotWords,
  })  : _getRecentWords = getRecentWords,
        _saveWord = saveWord,
        _deleteWord = deleteWord,
        _updateSentence = updateSentence,
        _searchWordDefinition = searchWordDefinition,
        _searchImages = searchImages,
        _saveWordImages = saveWordImages,
        _saveLotWords = saveLotWords,
        super(WordLearningInitial()) {
    // Eventos con sufijo "Event"
    on<LoadRecentWordsEvent>(_onLoadRecentWords);
    on<FetchWordsEvent>(_onFetchWords);
    on<SearchWordDefinitionEvent>(_onSearchWordDefinition);
    on<SearchWordImagesEvent>(_onSearchWordImages);
    on<SaveNewWordEvent>(_onSaveNewWord);
    on<UpdateWordSentenceEvent>(_onUpdateSentence);
    on<DeleteWordEvent>(_onDeleteWord);
    on<ChangePageEvent>(_onChangePage);
    on<InsertLotWordsEvent>(_onSaveLotWords);
  }

  Future<void> _onLoadRecentWords(
    LoadRecentWordsEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    emit(WordLearningLoading());
    try {
      final int limitUsed = event.limit ?? 9;
      final words = await _getRecentWords(
        limit: limitUsed, // Could be null
      );
      // #region agent log
      //try { File(r'd:\compartidoAtodos\proyectos\appIngles\.cursor\debug.log').writeAsStringSync(jsonEncode({'sessionId':'debug-session','hypothesisId':'H2','location':'word_learning_bloc.dart:_onLoadRecentWords','message':'Words loaded','data':{'limitUsed':limitUsed,'wordsLength':words.length},'timestamp':DateTime.now().millisecondsSinceEpoch}) + '\n', mode: FileMode.append); } catch (_) {}
      // #endregion
      if (event.limit == null) {}
      emit(WordsLoaded(words: words));
    } catch (e) {
      emit(WordLearningError(e.toString()));
    }
  }

  Future<void> _onFetchWords(
    FetchWordsEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    emit(WordLearningLoading());
    try {
      final words = await _getRecentWords(limit: event.limit);
      emit(WordsFetched(words));
    } catch (e) {
      emit(WordLearningError('Error fetching words: $e'));
    }
  }

  Future<void> _onSearchWordDefinition(
    SearchWordDefinitionEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    try {
      final meanings = await _searchWordDefinition(event.word);

      final meaningsMap = meanings.map((meaning) {
        return {
          'partOfSpeech': meaning.partOfSpeech,
          'definitions': meaning.definitions.map((def) {
            return {
              'definition': def.definition,
              'example': def.example,
            };
          }).toList(),
        };
      }).toList();

      emit(DefinitionsLoaded(meaningsMap));
    } catch (e) {
      emit(WordLearningError('Error buscando definiciones: $e'));
    }
  }

  Future<void> _onSearchWordImages(
    SearchWordImagesEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    try {
      final images = await _searchImages(event.query);
      emit(ImagesLoaded(images));
    } catch (e) {
      emit(WordLearningError('Error buscando imágenes: $e'));
    }
  }

  Future<void> _onSaveNewWord(
    SaveNewWordEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    try {
      final word = Word(
        word: event.wordData['word'],
        phonetic: event.wordData['phonetic'] ?? '',
        definition: event.wordData['definition'] ?? '',
        sentence: event.wordData['example'] ?? '',
        learnCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final wordId = await _saveWord(word);
      final savedImages = await _saveWordImages(
        event.selectedImages,
        wordId,
      );

      emit(WordSaved(wordId: wordId, imagesCount: savedImages.length));

      // Recargar palabras
      add(LoadRecentWordsEvent());
    } catch (e) {
      emit(WordLearningError('Error guardando palabra: $e'));
    }
  }

  Future<void> _onUpdateSentence(
    UpdateWordSentenceEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    try {
      await _updateSentence(event.wordId, event.newSentence);
      add(LoadRecentWordsEvent());
    } catch (e) {
      emit(WordLearningError('Error actualizando oración: $e'));
    }
  }

  Future<void> _onDeleteWord(
    DeleteWordEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    try {
      await _deleteWord(event.wordId);
      add(LoadRecentWordsEvent());
    } catch (e) {
      emit(WordLearningError('Error eliminando palabra: $e'));
    }
  }

  void _onChangePage(
    ChangePageEvent event,
    Emitter<WordLearningState> emit,
  ) {
    if (state is WordsLoaded) {
      final currentState = state as WordsLoaded;
      emit(WordsLoaded(words: currentState.words, currentPage: event.page));
    }
  }

  Future<void> _onSaveLotWords(
    InsertLotWordsEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    //emit(WordLearningLoading());
    try {
      final results = await _saveLotWords(event.words);
      emit(LotWordsInserted(results: results));

      // Optionally reload recent words
      add(LoadRecentWordsEvent());
    } catch (e) {
      emit(WordLearningError('Error inserting multiple words: $e'));
    }
  }
}
