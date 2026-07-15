import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/core/services/speech_to_text_service.dart';
import 'package:first_app/data/datasources/local/word_crud_dao.dart';
import 'package:first_app/data/datasources/local/word_practice_dao.dart';
import 'package:first_app/data/datasources/local/word_batch_dao.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';
import 'package:first_app/data/datasources/local/translation_dao.dart';
import 'package:first_app/data/datasources/remote/datamuse_service.dart';
import 'package:first_app/data/datasources/remote/dictionary_service.dart';
import 'package:first_app/data/datasources/remote/translation_service.dart';
import 'package:first_app/data/datasources/remote/unsplash_service.dart';
import 'package:first_app/data/repositories/datamuse_repository_impl.dart';
import 'package:first_app/domain/repositories/datamuse_repository.dart';
import 'package:first_app/domain/usecases/datamuse/get_means_like_words.dart';
import 'package:first_app/data/repositories/word_repository_impl.dart';
import 'package:first_app/data/repositories/image_repository_impl.dart';
import 'package:first_app/data/repositories/translation_repository_impl.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/repositories/image_repository.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/domain/services/tts_service_interface.dart';
import 'package:first_app/domain/services/speech_to_text_interface.dart';
import 'package:first_app/domain/usecases/word/save_word.dart';
import 'package:first_app/domain/usecases/word/delete_word.dart';
import 'package:first_app/domain/usecases/word/update_sentence.dart';
import 'package:first_app/domain/usecases/word/search_word_definition.dart';
import 'package:first_app/domain/usecases/word/get_recent_words_summary.dart';
import 'package:first_app/domain/usecases/word/get_recent_words.dart';
import 'package:first_app/domain/usecases/word/get_word_statistics.dart';
import 'package:first_app/domain/usecases/word/insert_lot_words.dart';
import 'package:first_app/domain/usecases/word/search_word_translation.dart';
import 'package:first_app/domain/usecases/image/search_images.dart';
import 'package:first_app/domain/usecases/image/save_word_images.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // === Data sources ===
  sl.registerLazySingleton<WordCrudDao>(() => WordCrudDao());
  sl.registerLazySingleton<WordPracticeDao>(() => WordPracticeDao());
  sl.registerLazySingleton<WordBatchDao>(() => WordBatchDao());
  sl.registerLazySingleton<ImageDao>(() => ImageDao());
  sl.registerLazySingleton<TranslationDao>(() => TranslationDao());

  sl.registerLazySingleton<WordService>(() => WordService());
  sl.registerLazySingleton<ImageService>(() => ImageService());
  sl.registerLazySingleton<TranslateService>(() => TranslateService());
  sl.registerLazySingleton<DatamuseService>(() => DatamuseService());

  // === Repositories ===
  sl.registerLazySingleton<WordRepository>(
    () => WordRepositoryImpl(
      wordCrudDao: sl<WordCrudDao>(),
      wordPracticeDao: sl<WordPracticeDao>(),
      wordBatchDao: sl<WordBatchDao>(),
      wordService: sl<WordService>(),
      translateService: sl<TranslateService>(),
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

  sl.registerLazySingleton<DatamuseRepository>(
    () => DatamuseRepositoryImpl(
      datamuseService: sl<DatamuseService>(),
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
  sl.registerLazySingleton<SearchWordTranslationUseCase>(
    () => SearchWordTranslationUseCase(sl<WordRepository>()),
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
  sl.registerLazySingleton<GetRecentWordsUseCase>(
    () => GetRecentWordsUseCase(sl<WordRepository>()),
  );

  sl.registerLazySingleton<GetMeansLikeWordsUseCase>(
    () => GetMeansLikeWordsUseCase(sl<DatamuseRepository>()),
  );

  // === Services ===
  sl.registerLazySingleton<ITtsService>(() => TtsService());
  sl.registerLazySingleton<ISpeechToTextService>(() => SpeechToTextService());

  // === Use cases (shared) ===
  sl.registerLazySingleton<ValidateWordAnswer>(() => ValidateWordAnswer());
  sl.registerLazySingleton<SpeakText>(() => SpeakText(sl<ITtsService>()));
}
