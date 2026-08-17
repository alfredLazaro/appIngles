import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/core/services/sync_scheduler.dart';
import 'package:first_app/core/services/sync_service.dart';
import 'package:first_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:first_app/presentation/bloc/auth/auth_event.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_event.dart';
import 'package:first_app/presentation/pages/auth_page.dart';
import 'package:first_app/presentation/widgets/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");
  setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SyncScheduler(
      syncService: sl<SyncService>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => sl<AuthBloc>()..add(const CheckAuth()),
          ),
          BlocProvider<WordLearningBloc>(
            create: (_) => WordLearningBloc(
              getRecentWords: sl(),
              getRecentWordsFull: sl(),
              saveWord: sl(),
              deleteWord: sl(),
              updateSentence: sl(),
              searchWordDefinition: sl(),
              searchImages: sl(),
              saveWordImages: sl(),
              saveLotWords: sl(),
              searchWordTranslation: sl(),
              getAlternativeTranslations: sl(),
              translationRepository: sl(),
            ),
          ),
          BlocProvider<WordListBloc>(
            create: (_) => WordListBloc(
              wordRepository: sl(),
              getWordStatisticsUseCase: sl(),
            )..add(const LoadWordsEvent()),
          ),
          BlocProvider<PracticeBloc>(
            create: (_) => PracticeBloc(
              wordRepository: sl(),
              imageRepository: sl(),
              translationRepository: sl(),
              progressRepository: sl(),
              connectivityService: sl(),
              syncService: sl(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Mi App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
              displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          home: const AuthGate(),
          routes: {
            '/auth': (_) => const AuthPage(),
            '/home': (_) => const AuthGate(),
          },
        ),
      ),
    );
  }
}