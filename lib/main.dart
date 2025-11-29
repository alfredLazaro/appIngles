import 'package:first_app/core/services/deep_ai_service.dart';
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
  await dotenv.load(fileName: "assets/.env"); //Cargar variables de entorno
  //sqfliteFfinit();
  await DeepSeekApiService().initialize(); // Inicializa el servicio de API
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar dependencias
    final wordDao = WordDao();
    final imageDao = ImageDao();
    final wordService = WordService();
    final imageService = ImageService();

    // Crear repositorios
    final wordRepository = WordRepositoryImpl(
      wordDao: wordDao,
      wordService: wordService,
    );

    final imageRepository = ImageRepositoryImpl(
      imageService: imageService,
      imageDao: imageDao,
    );

    // ✅ Crear casos de uso con sufijo "UseCase"
    final getRecentWords = GetRecentWordsSummaryUseCase(wordRepository);
    final saveWord = SaveWordUseCase(wordRepository);
    final deleteWord = DeleteWordUseCase(wordRepository);
    final updateSentence = UpdateSentenceUseCase(wordRepository);
    final searchWordDefinition = SearchWordDefinitionUseCase(wordRepository);
    final searchImages = SearchImagesUseCase(imageRepository);
    final saveWordImages = SaveWordImagesUseCase(imageRepository);
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
          getRecentWords: getRecentWords,
          saveWord: saveWord,
          deleteWord: deleteWord,
          updateSentence: updateSentence,
          searchWordDefinition: searchWordDefinition,
          searchImages: searchImages,
          saveWordImages: saveWordImages,
        ),
        child: const MainNavigationPage(),
      ),
    );
  }
}
/* 
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Pagina1(), //pantalla de inicio
    );
  }
} */
