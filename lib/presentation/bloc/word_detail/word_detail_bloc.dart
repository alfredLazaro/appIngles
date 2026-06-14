import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_image.dart';
import 'package:first_app/domain/repositories/image_repository.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/usecases/image/save_word_images.dart';
import 'package:first_app/domain/usecases/word/delete_word.dart';
import 'word_detail_event.dart';
import 'word_detail_state.dart';

class WordDetailBloc extends Bloc<WordDetailEvent, WordDetailState> {
  final WordRepository _wordRepository;
  final TranslationRepository _translationRepository;
  final ImageRepository _imageRepository;
  final DeleteWordUseCase _deleteWordUseCase;
  final SaveWordImagesUseCase _saveWordImages;

  WordDetailBloc({
    required WordRepository wordRepository,
    required TranslationRepository translationRepository,
    required ImageRepository imageRepository,
    required DeleteWordUseCase deleteWordUseCase,
    required SaveWordImagesUseCase saveWordImages,
  })  : _wordRepository = wordRepository,
        _translationRepository = translationRepository,
        _imageRepository = imageRepository,
        _deleteWordUseCase = deleteWordUseCase,
        _saveWordImages = saveWordImages,
        super(const WordDetailInitial()) {
    on<LoadWordDetailEvent>(_onLoad);
    on<SaveWordDetailEvent>(_onSave);
    on<DeleteWordDetailEvent>(_onDelete);
    on<AddImagesToWordEvent>(_onAddImages);
  }

  Future<void> _onLoad(
    LoadWordDetailEvent event,
    Emitter<WordDetailState> emit,
  ) async {
    emit(const WordDetailLoading());
    try {
      final results = await Future.wait([
        _wordRepository.getWordById(event.wordId),
        _translationRepository.getTranslationsByWordId(event.wordId),
        _imageRepository.getImagesByWordId(event.wordId),
      ]);
      final word = results[0] as Word;
      final translations = results[1] as List<TranslationEntity>;
      final images = results[2] as List<WordImage>;
      emit(WordDetailLoaded(word: word, translations: translations, images: images));
    } catch (e) {
      emit(WordDetailError('Error al cargar: $e'));
    }
  }

  Future<void> _onSave(
    SaveWordDetailEvent event,
    Emitter<WordDetailState> emit,
  ) async {
    if (state is! WordDetailLoaded) return;
    final loaded = state as WordDetailLoaded;
    emit(loaded.copyWith(isSaving: true, clearError: true));

    try {
      await _wordRepository.updateWord(event.updatedWord);

      for (final id in event.translationIdsToDelete) {
        await _translationRepository.deleteTranslation(id);
      }
      if (event.newTranslations.isNotEmpty) {
        await _translationRepository.insertTranslations(
          event.updatedWord.id!,
          event.newTranslations,
        );
      }

      final reloadedTranslations =
          await _translationRepository.getTranslationsByWordId(event.updatedWord.id!);

      emit(loaded.copyWith(
        word: event.updatedWord,
        translations: reloadedTranslations,
        isSaving: false,
      ));
    } catch (e) {
      emit(loaded.copyWith(isSaving: false, errorMessage: 'Error al guardar: $e'));
    }
  }

  Future<void> _onDelete(
    DeleteWordDetailEvent event,
    Emitter<WordDetailState> emit,
  ) async {
    try {
      await _deleteWordUseCase.call(event.wordId);
      emit(const WordDetailDeleted());
    } catch (e) {
      if (state is WordDetailLoaded) {
        emit((state as WordDetailLoaded).copyWith(
          errorMessage: 'Error al eliminar: $e',
        ));
      } else {
        emit(WordDetailError('Error al eliminar: $e'));
      }
    }
  }

  Future<void> _onAddImages(
    AddImagesToWordEvent event,
    Emitter<WordDetailState> emit,
  ) async {
    if (state is! WordDetailLoaded) return;
    final loaded = state as WordDetailLoaded;
    emit(loaded.copyWith(isSaving: true));

    try {
      await _saveWordImages(event.images, loaded.word.id!);
      final updatedImages =
          await _imageRepository.getImagesByWordId(loaded.word.id!);
      emit(loaded.copyWith(images: updatedImages, isSaving: false));
    } catch (e) {
      emit(loaded.copyWith(
          isSaving: false, errorMessage: 'Error al agregar imágenes: $e'));
    }
  }
}
