import 'package:first_app/main.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_event.dart';
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

  // Create blocs once
  late final WordLearningBloc wordLearningBloc;
  late final WordListBloc wordListBloc;

  @override
  void initState() {
    super.initState();
    final deps = Dependencies.instance;

    wordLearningBloc = WordLearningBloc(
      getRecentWords: deps.getRecentWords,
      saveWord: deps.saveWord,
      deleteWord: deps.deleteWord,
      updateSentence: deps.updateSentence,
      searchWordDefinition: deps.searchWordDefinition,
      searchImages: deps.searchImages,
      saveWordImages: deps.saveWordImages,
    );

    wordListBloc = WordListBloc(
        wordRepository: deps.wordRepository,
        imageRepository: deps.imageRepository)
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
            if (index == 1) {
              wordListBloc.add(const LoadWordsEvent());
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Aprender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mis Palabras',
          ),
        ],
      ),
    );
  }
}
