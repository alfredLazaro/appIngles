import 'package:bloc/bloc.dart';
import 'package:first_app/domain/entities/match_round.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/repositories/image_repository.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'practice_event.dart';
import 'practice_state.dart';

class PracticeBloc extends Bloc<PracticeEvent, PracticeState> {
  final WordRepository _wordRepository;
  final ImageRepository _imageRepository;
  final TranslationRepository _translationRepository;

  PracticeBloc({
    required WordRepository wordRepository,
    required ImageRepository imageRepository,
    required TranslationRepository translationRepository,
  })  : _wordRepository = wordRepository,
        _imageRepository = imageRepository,
        _translationRepository = translationRepository,
        super(PracticeInitial()) {
    on<LoadPracticeDataEvent>(_onLoadPracticeData);
    on<StartPracticeEvent>(_onStartPractice);
  }

  Future<void> _onLoadPracticeData(
    LoadPracticeDataEvent event,
    Emitter<PracticeState> emit,
  ) async {
    emit(PracticeLoading());

    try {
      int totalCount;

      // Get count based on practice type
      switch (event.type) {
        case PracticeType.flashcard:
        case PracticeType.spelling:
        case PracticeType.listening:
        case PracticeType.matching:
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

      if (event.type == PracticeType.matching && totalCount < 2) {
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

        case PracticeType.spelling:
        case PracticeType.listening:
          throw UnimplementedError('Práctica no disponible aún');
      }
      emit(PracticeReady(practiceData));
    } catch (e) {
      emit(PracticeError('Error al preparar práctica: $e'));
    }
  }

  Future<FlashcardPracticeData> _loadFlashcardPractice(int count) async {
    // Load words for practice
    final words = await _wordRepository.getWordsForPractice(count);

    // Get word IDs
    final wordIds = words.map((w) => w.id).toList();

    // Load images
    final images = await _imageRepository.getImagesByWordIds(wordIds);
    return FlashcardPracticeData(
      words: words,
      imagesMap: images,
    );
  }

  Future<MatchingPracticeData> _loadMatchingPractice(int count) async {
    final words = await _wordRepository.getWordsForPractice(count);
    final wordIds = words.map((w) => w.id).toList();
    final translations =
        await _translationRepository.getTranslationsByWordIds(wordIds);
    final rounds = MatchRound.generateRounds(
      allWords: words,
      allTranslations: translations,
      batchSize: 4,
    );
    return MatchingPracticeData(
      words: words,
      rounds: rounds,
    );
  }

  Future<SentencePracticeData> _loadSentencePractice(int count) async {
    // Load sentences for practice
    final sentences =
        await _wordRepository.getSentencesForPractice(limit: count);

    return SentencePracticeData(
      sentences: sentences,
    );
  }
}
