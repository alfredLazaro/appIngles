import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/data/datasources/local/word_dao.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';
import 'package:first_app/data/datasources/local/translation_dao.dart';
import 'package:first_app/data/datasources/remote/dictionary_service.dart';
import 'package:first_app/data/datasources/remote/unsplash_service.dart';
import 'package:first_app/data/repositories/word_repository_impl.dart';
import 'package:first_app/data/repositories/image_repository_impl.dart';
import 'package:first_app/data/repositories/translation_repository_impl.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/repositories/image_repository.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/domain/usecases/word/save_word.dart';
import 'package:first_app/domain/usecases/word/delete_word.dart';
import 'package:first_app/domain/usecases/word/update_sentence.dart';
import 'package:first_app/domain/usecases/word/search_word_definition.dart';
import 'package:first_app/domain/usecases/word/get_recent_words_summary.dart';
import 'package:first_app/domain/usecases/word/get_word_statistics.dart';
import 'package:first_app/domain/usecases/word/insert_lot_words.dart';
import 'package:first_app/domain/usecases/image/search_images.dart';
import 'package:first_app/domain/usecases/image/save_word_images.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // === Data sources ===
  sl.registerLazySingleton<WordDao>(() => WordDao());
  sl.registerLazySingleton<ImageDao>(() => ImageDao());
  sl.registerLazySingleton<TranslationDao>(() => TranslationDao());

  sl.registerLazySingleton<WordService>(() => WordService());
  sl.registerLazySingleton<ImageService>(() => ImageService());

  // === Repositories ===
  sl.registerLazySingleton<WordRepository>(
    () => WordRepositoryImpl(
      wordDao: sl<WordDao>(),
      wordService: sl<WordService>(),
    ),
  );

  sl.registerLazySingleton<ImageRepository>(
    () => ImageRepositoryImpl(
      imageService: sl<ImageService>(),
      imageDao: sl<ImageDao>(),
    ),
  );

  sl.registerLazySingleton<TranslationRepository>(
    () => TranslationRepositoryImpl(
      translationDao: sl<TranslationDao>(),
    ),
  );

  // === Use cases ===
  sl.registerLazySingleton<GetRecentWordsSummaryUseCase>(
    () => GetRecentWordsSummaryUseCase(sl<WordRepository>()),
  );
  sl.registerLazySingleton<SaveWordUseCase>(
    () => SaveWordUseCase(sl<WordRepository>()),
  );
  sl.registerLazySingleton<DeleteWordUseCase>(
    () => DeleteWordUseCase(sl<WordRepository>()),
  );
  sl.registerLazySingleton<UpdateSentenceUseCase>(
    () => UpdateSentenceUseCase(sl<WordRepository>()),
  );
  sl.registerLazySingleton<SearchWordDefinitionUseCase>(
    () => SearchWordDefinitionUseCase(sl<WordRepository>()),
  );
  sl.registerLazySingleton<SearchImagesUseCase>(
    () => SearchImagesUseCase(sl<ImageRepository>()),
  );
  sl.registerLazySingleton<SaveWordImagesUseCase>(
    () => SaveWordImagesUseCase(sl<ImageRepository>()),
  );
  sl.registerLazySingleton<InsertLotWordsUseCase>(
    () => InsertLotWordsUseCase(sl<WordRepository>()),
  );
  sl.registerLazySingleton<GetWordStatisticsUseCase>(
    () => GetWordStatisticsUseCase(sl<WordRepository>()),
  );

  // === Services ===
  sl.registerLazySingleton<TtsService>(() => TtsService());

  // === Use cases (shared) ===
  sl.registerLazySingleton<ValidateWordAnswer>(() => ValidateWordAnswer());
  sl.registerLazySingleton<SpeakText>(() => SpeakText(sl<TtsService>()));
}
