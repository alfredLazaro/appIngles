import 'package:first_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_event.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_state.dart';
import 'package:first_app/presentation/widgets/ListaCards.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';

class WordListPage extends StatelessWidget {
  const WordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Words"),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () => _navigateToPracticeHub(context),
            tooltip: 'Prácticas',
          ),
        ],
      ),
      body: BlocBuilder<WordListBloc, WordListState>(
        builder: (context, state) {
          if (state is WordListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WordListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WordListBloc>().add(const LoadWordsEvent());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is WordListLoaded) {
            return const ListaCards();
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToPracticeHub(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PracticeSelectionPage(),
      ),
    );

    if (context.mounted) {
      context.read<WordListBloc>().add(const RefreshWordsEvent());
    }
  }

/*   void _navigateToSentencePractice(BuildContext context) async {
    final bloc = context.read<WordListBloc>();
    final deps = Dependencies.instance;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeSelectionPage(
          practiceType: PracticeType.sentence,
          wordRepository: deps.wordRepository, 
          imageRepository: deps.imageRepository,
        ),
      ),
    );

    bloc.add(const RefreshWordsEvent());
  } */
}
