import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_event.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_state.dart';
import 'package:first_app/presentation/pages/word_detail_screen.dart';
import 'package:first_app/presentation/widgets/WordCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class ListaCards extends StatefulWidget {
  const ListaCards({super.key});

  @override
  State<ListaCards> createState() => _ListaCardsState();
}

class _ListaCardsState extends State<ListaCards> {
  final TtsService _ttsService = TtsService();
  final ScrollController _scrollController = ScrollController();
  final log = Logger();

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize(
      language: 'en-US',
      pitch: 1.0,
      speechRate: 0.5,
    );
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<WordListBloc>().state;
      if (state is WordListLoaded &&
          state.hasMorePages &&
          !state.isLoadingMore) {
        context.read<WordListBloc>().add(const LoadMoreWordsEvent());
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> speakf(String text) async {
    try {
      await _ttsService.speak(text);
    } catch (e) {
      log.e('Error al leer el texto: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  void _navigateToWordDetail(WordWithImage word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordDetailScreen(
          wordWithImage: word,
          onWordUpdated: () {
            context.read<WordListBloc>().add(const RefreshWordsEvent());
          },
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordListBloc, WordListState>(
      builder: (context, state) {
        if (state is WordListLoaded) {
          if (state.words.isEmpty) {
            return const Center(
              child: Text('No hay palabras en esta sección.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WordListBloc>().add(const RefreshWordsEvent());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.words.length + (state.hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator at bottom
                if (index >= state.words.length) {
                  return _buildLoadingIndicator();
                }

                final word = state.words[index];
                return WordCard(
                  word: word,
                  onSpeak: () => speakf(word.word),
                  onTapImage: () => _navigateToWordDetail(word),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
