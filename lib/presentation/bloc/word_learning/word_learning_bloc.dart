import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/domain/usecases/word/get_recent_words_summary.dart';
import 'package:first_app/domain/usecases/word/get_recent_words.dart';
import 'package:first_app/domain/usecases/word/search_word_translation.dart';
import 'package:first_app/domain/usecases/word/get_alternative_translations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_meaning.dart';
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
  final GetRecentWordsUseCase _getRecentWordsFull;
  final SaveWordUseCase _saveWord;
  final DeleteWordUseCase _deleteWord;
  final UpdateSentenceUseCase _updateSentence;
  final SearchWordDefinitionUseCase _searchWordDefinition;
  final SearchImagesUseCase _searchImages;
  final SaveWordImagesUseCase _saveWordImages;
  final InsertLotWordsUseCase _saveLotWords;
  final SearchWordTranslationUseCase _searchWordTranslation;
  final GetAlternativeTranslationsUseCase _getAlternativeTranslations;
  final TranslationRepository _translationRepository;

  WordLearningBloc({
    required GetRecentWordsSummaryUseCase getRecentWords,
    required GetRecentWordsUseCase getRecentWordsFull,
    required SaveWordUseCase saveWord,
    required DeleteWordUseCase deleteWord,
    required UpdateSentenceUseCase updateSentence,
    required SearchWordDefinitionUseCase searchWordDefinition,
    required SearchImagesUseCase searchImages,
    required SaveWordImagesUseCase saveWordImages,
    required InsertLotWordsUseCase saveLotWords,
    required SearchWordTranslationUseCase searchWordTranslation,
    required GetAlternativeTranslationsUseCase getAlternativeTranslations,
    required TranslationRepository translationRepository,
  })  : _getRecentWords = getRecentWords,
        _getRecentWordsFull = getRecentWordsFull,
        _saveWord = saveWord,
        _deleteWord = deleteWord,
        _updateSentence = updateSentence,
        _searchWordDefinition = searchWordDefinition,
        _searchImages = searchImages,
        _saveWordImages = saveWordImages,
        _saveLotWords = saveLotWords,
        _searchWordTranslation = searchWordTranslation,
        _getAlternativeTranslations = getAlternativeTranslations,
        _translationRepository = translationRepository,
        super(WordLearningInitial()) {
    // Eventos con sufijo "Event"
    on<LoadRecentWordsEvent>(_onLoadRecentWords);
    on<FetchWordsEvent>(_onFetchWords);
    on<SearchWordEvent>(_onSearchWord);
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
      final words = await _getRecentWordsFull(limit: event.limit);
      emit(WordsFetched(words));
    } catch (e) {
      emit(WordLearningError('Error fetching words: $e'));
    }
  }

  Future<void> _onSearchWord(
    SearchWordEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    emit(WordLearningLoading());
    try {
      final results = await Future.wait([
        _searchWordDefinition(event.word),
        _searchImages(event.word),
        _searchWordTranslation(event.word),
        _getAlternativeTranslations(event.word),
      ]);

      final meanings = (results[0] as List<WordMeaning>).map((m) {
        return {
          'partOfSpeech': m.partOfSpeech,
          'definitions': m.definitions.map((d) {
            return {
              'definition': d.definition,
              'example': d.example,
              'phonetic': d.phonetic,
            };
          }).toList(),
        };
      }).toList();

      final images = results[1] as List<ImageSearchResult>;
      final translation = results[2] as Map<String, dynamic>?;
      final alternativeTranslations = results[3] as Map<String, String>;

      emit(WordDataLoaded(
        meanings: meanings,
        images: images,
        translation: translation,
        alternativeTranslations: alternativeTranslations,
      ));
    } catch (e) {
      emit(WordLearningError('Error al buscar datos: $e'));
    }
  }

  Future<void> _onSearchWordImages(
    SearchWordImagesEvent event,
    Emitter<WordLearningState> emit,
  ) async {
    try {
      final images = await _searchImages(event.query);
      emit(ImagesLoaded(images: images));
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
        partOfSpeech: event.wordData['partOfSpeech'] ?? '',
        phonetic: event.wordData['phonetic'] ?? '',
        definition: event.wordData['definition'] ?? '',
        sentence: event.wordData['example'] ?? '',
        learnCount: 0,
        synonyms: event.selectedEnglishSynonyms.join('|'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final wordId = await _saveWord(word);
      final savedImages = await _saveWordImages(
        event.selectedImages,
        wordId,
      );

      if (event.translation != null &&
          event.translation!['translatedText'] != null) {
        await _translationRepository.insertTranslation(
          wordId,
          event.translation!['translatedText'] as String,
          event.selectedAlternatives,
        );
      }

      emit(WordSaved(wordId: wordId, imagesCount: savedImages.length));

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
      if (event.onCompleted != null) event.onCompleted!();

      // Optionally reload recent words
      add(LoadRecentWordsEvent());
    } catch (e) {
      emit(WordLearningError('Error inserting multiple words: $e'));
    }
  }
}
