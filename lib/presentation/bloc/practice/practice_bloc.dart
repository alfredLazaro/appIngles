import 'package:bloc/bloc.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/repositories/image_repository.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
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
      final totalCount = await _wordRepository.countWords();
      
      if (totalCount == 0) {
        emit(const PracticeError('No hay palabras para practicar'));
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
      // Load words for practice
      final words = await _wordRepository.getWordsForPractice(event.count);
      
      // Get word IDs
      final wordIds = words.map((w) => w.id).toList();
      
      // Load images
      final imagesMap = await _imageRepository.getImagesByWordIds(wordIds);
      
      // Create practice data
      final practiceData = PracticeData(
        words: words,
        imagesMap: imagesMap,
      );

      emit(PracticeReady(practiceData));
    } catch (e) {
      emit(PracticeError('Error al preparar práctica: $e'));
    }
  }
}