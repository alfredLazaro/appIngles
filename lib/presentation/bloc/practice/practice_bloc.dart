import 'package:bloc/bloc.dart';
import 'package:first_app/data/mappers/image_mapper.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/repositories/image_repository.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'practice_event.dart';
import 'practice_state.dart';

class PracticeBloc extends Bloc<PracticeEvent, PracticeState> {
  final WordRepository _wordRepository;
  final ImageRepository _imageRepository;

  PracticeBloc({
    required WordRepository wordRepository,
    required ImageRepository imageRepository,
  })  : _wordRepository = wordRepository,
        _imageRepository = imageRepository,
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
          print('📚 Loading flashcard data...');
          practiceData = await _loadFlashcardPractice(event.count);
          print(
              '✅ Flashcard data loaded: ${(practiceData as FlashcardPracticeData).words.length} words');
          break;

        case PracticeType.sentence:
          print('📝 Loading sentence data...');
          practiceData = await _loadSentencePractice(event.count);
          print(
              '✅ Sentence data loaded: ${(practiceData as SentencePracticeData).sentences.length} sentences');
          break;

        case PracticeType.spelling:
        case PracticeType.listening:
          print('⚠️ Practice type not implemented: ${event.type}');
          throw UnimplementedError('Práctica no disponible aún');
      }

      print('✅ Emitting PracticeReady state');
      emit(PracticeReady(practiceData));
    } catch (e, stackTrace) {
      print('❌ Error preparing practice: $e');
      print('Stack trace: $stackTrace');
      emit(PracticeError('Error al preparar práctica: $e'));
    }
  }

  Future<FlashcardPracticeData> _loadFlashcardPractice(int count) async {
    // Load words for practice
    final words = await _wordRepository.getWordsForPractice(count);

    // Get word IDs
    final wordIds = words.map((w) => w.id).toList();

    // Load images
    final imagesMap = await _imageRepository.getImagesByWordIds(wordIds);
    Map<int, List<FlashcardImage>> images =
        ImageMapper.mapToFlashcardImages(imagesMap);
    return FlashcardPracticeData(
      words: words,
      imagesMap: images,
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
