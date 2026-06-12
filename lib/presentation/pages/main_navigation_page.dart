import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_event.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:first_app/presentation/pages/word_learning_page.dart';
import 'package:first_app/presentation/pages/word_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  late final WordLearningBloc wordLearningBloc;
  late final WordListBloc wordListBloc;

  @override
  void initState() {
    super.initState();

    wordLearningBloc = WordLearningBloc(
      getRecentWords: sl(),
      saveWord: sl(),
      deleteWord: sl(),
      updateSentence: sl(),
      searchWordDefinition: sl(),
      searchImages: sl(),
      saveWordImages: sl(),
      saveLotWords: sl(),
    );

    wordListBloc = WordListBloc(
        wordRepository: sl(),
        imageRepository: sl(),
        getWordStatisticsUseCase: sl())
      ..add(const LoadWordsEvent());
  }

  @override
  void dispose() {
    wordLearningBloc.close();
    wordListBloc.close();
    super.dispose();
  }

  List<Widget> get _pages => [
        BlocProvider.value(
          value: wordLearningBloc,
          child: const WordLearningPage(),
        ),
        const PracticeSelectionPage(),
        BlocProvider.value(
          value: wordListBloc,
          child: const WordListPage(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 2) {
              wordListBloc.add(const LoadWordsEvent());
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Aprender',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "d"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mis Palabras',
          ),
        ],
      ),
    );
  }
}
