import 'package:bloc/bloc.dart';
import 'package:first_app/core/services/connectivity_service.dart';
import 'package:first_app/core/services/sync_service.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/match_round.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/repositories/image_repository.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:logger/logger.dart';
import 'practice_event.dart';
import 'practice_state.dart';

class PracticeBloc extends Bloc<PracticeEvent, PracticeState> {
  final WordRepository _wordRepository;
  final ImageRepository _imageRepository;
  final TranslationRepository _translationRepository;
  final SyncService? _syncService;
  final ConnectivityService _connectivityService;

  PracticeBloc({
    required WordRepository wordRepository,
    required ImageRepository imageRepository,
    required TranslationRepository translationRepository,
    required ConnectivityService connectivityService,
    SyncService? syncService,
  })  : _wordRepository = wordRepository,
        _imageRepository = imageRepository,
        _translationRepository = translationRepository,
        _connectivityService = connectivityService,
        _syncService = syncService,
        super(PracticeInitial()) {
    on<LoadPracticeDataEvent>(_onLoadPracticeData);
    on<StartPracticeEvent>(_onStartPractice);
    on<FinishPracticeEvent>(_onFinishPractice);
  }

  Future<void> _onLoadPracticeData(
    LoadPracticeDataEvent event,
    Emitter<PracticeState> emit,
  ) async {
    emit(PracticeLoading());

    try {
      int totalCount;

      switch (event.type) {
        case PracticeType.flashcard:
        case PracticeType.spelling:
        case PracticeType.listening:
        case PracticeType.matching:
        case PracticeType.matchingDefinition:
          totalCount = await _wordRepository.getTotalWordCount();
          break;
        case PracticeType.sentence:
          totalCount = await _wordRepository.countSentences();
          break;
      }

      if (totalCount == 0) {
        final message = event.type == PracticeType.sentence
            ? 'No hay oraciones para practicar'
            : 'No hay palabras para practicar';
        emit(PracticeError(message));
        return;
      }

      if ((event.type == PracticeType.matching ||
              event.type == PracticeType.matchingDefinition) &&
          totalCount < 2) {
        emit(const PracticeError(
            'Se necesitan al menos 2 palabras para emparejar'));
        return;
      }

      emit(PracticeDataLoaded(totalCount));
    } catch (e) {
      emit(PracticeError('Error al cargar datos: $e'));
    }
  }

  Future<void> _onStartPractice(
    StartPracticeEvent event,
    Emitter<PracticeState> emit,
  ) async {
    emit(PracticeLoading());

    try {
      if (event.type == PracticeType.sentence) {
        final hasInternet = await _connectivityService.hasInternet();
        if (!hasInternet) {
          emit(const PracticeError(
              'Se requiere conexión a internet para iniciar la práctica'));
          return;
        }
      }

      PracticeData practiceData;

      switch (event.type) {
        case PracticeType.flashcard:
          practiceData = await _loadFlashcardPractice(event.count);
          break;

        case PracticeType.sentence:
          practiceData = await _loadSentencePractice(event.count);
          break;

        case PracticeType.matching:
          practiceData = await _loadMatchingPractice(event.count);
          break;

        case PracticeType.matchingDefinition:
          practiceData = await _loadMatchingDefPractice(event.count);
          break;

        case PracticeType.listening:
          practiceData = await _loadListeningPractice(
            event.count,
            maxAudioPlays: event.maxAudioPlays,
          );
          break;

        case PracticeType.spelling:
          throw UnimplementedError('Práctica no disponible aún');
      }
      emit(PracticeReady(practiceData));
    } catch (e) {
      emit(PracticeError('Error al preparar práctica: $e'));
    }
  }

  Future<FlashcardPracticeData> _loadFlashcardPractice(int count) async {
    final words = await _wordRepository.getWordsForPractice(count);
    final word_ids = words.map((w) => w.id).toList();
    final images = await _imageRepository.getImagesByword_ids(word_ids);
    return FlashcardPracticeData(
      words: words,
      imagesMap: images,
    );
  }

  Future<MatchingPracticeData> _loadMatchingPractice(int count) async {
    final words = await _wordRepository.getWordsForPractice(count);
    final word_ids = words.map((w) => w.id).toList();
    final translations =
        await _translationRepository.getTranslationsByword_ids(word_ids);
    final rounds = MatchRound.generateRounds(
      allWords: words,
      allTranslations: translations,
      batchSize: 6
    );
    return MatchingPracticeData(
      words: words,
      rounds: rounds,
    );
  }

  Future<SentencePracticeData> _loadSentencePractice(int count) async {
    final sentences =
        await _wordRepository.getSentencesForPractice(limit: count);
    return SentencePracticeData(
      sentences: sentences,
    );
  }

  Future<MatchingDefPracticeData> _loadMatchingDefPractice(int count) async {
    final wordDefs = await _wordRepository.gettWordDefForPractice(count);
    final rounds = MatchRound.generateDefRounds(allWords: wordDefs);
    final flashcardWords = wordDefs
        .map((wd) => FlashcardWord(
              id: wd.id,
              word: wd.word,
              definition: wd.definition,
              sentence: '',
            ))
        .toList();
    Logger log = Logger();
    log.d('words: ${wordDefs.length}, rounds: ${rounds.length}');
    log.i(rounds);
    return MatchingDefPracticeData(
      words: flashcardWords,
      rounds: rounds,
    );
  }

  Future<ListeningPracticeData> _loadListeningPractice(
    int count, {
    int maxAudioPlays = 0,
  }) async {
    final words = await _wordRepository.getWordsForPractice(count);
    return ListeningPracticeData(
      words: words,
      maxAudioPlays: maxAudioPlays,
    );
  }

  Future<void> _onFinishPractice(
    FinishPracticeEvent event,
    Emitter<PracticeState> emit,
  ) async {
    try {
      await _wordRepository
          .batchUpdateLearnCounts(event.result.learnCountUpdates);
      _syncService?.onPracticeCompleted();
      emit(PracticeCompleted(event.result));
    } catch (e) {
      emit(PracticeError('Error al guardar progreso: $e'));
    }
  }
}