import 'package:first_app/domain/usecases/word/get_recent_words_summary.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/services/dictonary_service.dart';
import 'package:first_app/core/services/apiImage.dart';
import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';
import 'package:first_app/data/repositories/word_repository_impl.dart';
import 'package:first_app/data/repositories/image_repository_impl.dart';
//Importar con sufijo "UseCase"
import 'package:first_app/domain/usecases/word/save_word.dart';
import 'package:first_app/domain/usecases/word/delete_word.dart';
import 'package:first_app/domain/usecases/word/update_sentence.dart';
import 'package:first_app/domain/usecases/word/search_word_definition.dart';
import 'package:first_app/domain/usecases/image/search_images.dart';
import 'package:first_app/domain/usecases/image/save_word_images.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_bloc.dart';
import 'package:first_app/presentation/pages/main_navigation_page.dart';

//import 'package:sqflite_common_ffi/sqflite_ffi.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Cargar .env en background (no bloquear el UI)
  runApp(const AppLoader());

  // ✅ Cargar .env DESPUÉS de mostrar la UI
  await dotenv.load(fileName: "assets/.env");
}

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Cargando...'),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          // ✅ Una vez cargado, mostrar app real
          return const MyApp();
        },
      ),
    );
  }

  Future<void> _initializeApp() async {
    // Cargar .env si no se ha cargado
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: "assets/.env");
    }

    // ✅ Dar tiempo para que la UI se renderice
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

class Dependencies {
  static Dependencies? _instance;

  // Lazy initialization
  late final WordDao wordDao;
  late final ImageDao imageDao;
  late final WordService wordService;
  late final ImageService imageService;
  late final WordRepositoryImpl wordRepository;
  late final ImageRepositoryImpl imageRepository;

  // Use cases
  late final GetRecentWordsSummaryUseCase getRecentWords;
  late final SaveWordUseCase saveWord;
  late final DeleteWordUseCase deleteWord;
  late final UpdateSentenceUseCase updateSentence;
  late final SearchWordDefinitionUseCase searchWordDefinition;
  late final SearchImagesUseCase searchImages;
  late final SaveWordImagesUseCase saveWordImages;

  Dependencies._() {
    // ✅ Inicializar UNA SOLA VEZ
    wordDao = WordDao();
    imageDao = ImageDao();
    wordService = WordService();
    imageService = ImageService();

    wordRepository = WordRepositoryImpl(
      wordDao: wordDao,
      wordService: wordService,
    );

    imageRepository = ImageRepositoryImpl(
      imageService: imageService,
      imageDao: imageDao,
    );

    // Casos de uso
    getRecentWords = GetRecentWordsSummaryUseCase(wordRepository);
    saveWord = SaveWordUseCase(wordRepository);
    deleteWord = DeleteWordUseCase(wordRepository);
    updateSentence = UpdateSentenceUseCase(wordRepository);
    searchWordDefinition = SearchWordDefinitionUseCase(wordRepository);
    searchImages = SearchImagesUseCase(imageRepository);
    saveWordImages = SaveWordImagesUseCase(imageRepository);
  }

  static Dependencies get instance {
    _instance ??= Dependencies._();
    return _instance!;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Obtener dependencias del singleton (no crear nuevas)
    final deps = Dependencies.instance;

    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
              fontSize: 16, color: Colors.black), // bodyText1 -> bodyMedium
          displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold), // headline1 -> displayLarge
        ),
      ),
      home: BlocProvider(
        create: (context) => WordLearningBloc(
          getRecentWords: deps.getRecentWords,
          saveWord: deps.saveWord,
          deleteWord: deps.deleteWord,
          updateSentence: deps.updateSentence,
          searchWordDefinition: deps.searchWordDefinition,
          searchImages: deps.searchImages,
          saveWordImages: deps.saveWordImages,
        ),
        child: const MainNavigationPage(),
      ),
    );
  }
}
