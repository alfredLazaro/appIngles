import 'package:first_app/presentation/widgets/sentence/word_stats_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:first_app/presentation/bloc/auth/auth_state.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_event.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_state.dart';
import 'package:first_app/presentation/widgets/ListaCards.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:first_app/presentation/widgets/app_drawer.dart';

class WordListPage extends StatelessWidget {
  const WordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthBloc>().state is AuthSuccess;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text("My Words"),
        actions: [
          BlocBuilder<WordListBloc, WordListState>(
            builder: (context, state) {
              if (state is WordListLoaded && state.stats != null) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: WordStatsWidget(
                    stats: state.stats!,
                    compact: true,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () => _navigateToPracticeHub(context),
            tooltip: 'Prácticas',
          ),
        ],
        bottom: isLoggedIn
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/auth'),
                  child: Container(
                    width: double.infinity,
                    color: Colors.orange.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Inicia sesión para sincronizar tu progreso',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 16, color: Colors.orange.shade800),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      body: BlocBuilder<WordListBloc, WordListState>(
        builder: (context, state) => _buildBody(context, state),
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

  Widget _buildBody(BuildContext context, WordListState state) {
    if (state is WordListInitial || state is WordListLoading) {
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
                context.read<WordListBloc>().add(const RefreshWordsEvent());
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
  }
}
