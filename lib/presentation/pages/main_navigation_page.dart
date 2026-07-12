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

  List<Widget> get _pages => [
        const WordLearningPage(),
        const PracticeSelectionPage(),
        const WordListPage(),
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
              context.read<WordListBloc>().add(const LoadWordsEvent());
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Aprender',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Practica"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mis Palabras',
          ),
        ],
      ),
    );
  }
}
