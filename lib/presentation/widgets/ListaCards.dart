import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/domain/entities/word_filter.dart';
import 'package:first_app/domain/services/tts_service_interface.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/presentation/bloc/word_detail/word_detail_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_event.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_state.dart';
import 'package:first_app/presentation/pages/word_detail_screen.dart';
import 'package:first_app/presentation/widgets/WordCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:logger/logger.dart';

class ListaCards extends StatefulWidget {
  const ListaCards({super.key});

  @override
  State<ListaCards> createState() => _ListaCardsState();
}

class _ListaCardsState extends State<ListaCards> {
  final ITtsService _ttsService = sl<ITtsService>();
  final ScrollController _scrollController = ScrollController();
  final log = Logger();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollDebounced);
  }

  void _onScrollDebounced() {
    if (_isBottom) {
      _loadMoreIfNeeded();
    }
  }

  void _loadMoreIfNeeded() {
    final state = context.read<WordListBloc>().state;
    if (state is WordListLoaded &&
        state.hasMorePages &&
        !state.isLoadingMore) {
      context.read<WordListBloc>().add(const LoadMoreWordsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * AppLayout.scrollLoadThreshold);
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
    _scrollController.removeListener(_onScrollDebounced);
    _scrollController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  void _navigateToWordDetail(WordWithImage word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => WordDetailBloc(
            wordRepository: sl(),
            translationRepository: sl(),
            imageRepository: sl(),
            deleteWordUseCase: sl(),
            saveWordImages: sl(),
          ),
          child: WordDetailScreen(
            wordWithImage: word,
            onWordUpdated: () {
              context.read<WordListBloc>().add(const RefreshWordsEvent());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(WordFilterMode currentMode) {
    const filters = {
      WordFilterMode.all: 'Todas',
      WordFilterMode.noTranslation: 'Sin traducción',
      WordFilterMode.noSentence: 'Sin frase',
      WordFilterMode.incomplete: 'Incompletas',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: DropdownButton<WordFilterMode>(
        value: currentMode,
        isExpanded: true,
        underline: const SizedBox(),
        items: filters.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: (mode) {
          if (mode != null) {
            context.read<WordListBloc>().add(SetFilterEvent(mode));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WordListBloc, WordListState>(
      listenWhen: (previous, current) =>
          current is WordListLoaded &&
          current.errorMessage != null &&
          current.errorMessage !=
              (previous is WordListLoaded ? previous.errorMessage : null),
      listener: (context, state) {
        if (state is WordListLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: BlocBuilder<WordListBloc, WordListState>(
        builder: (context, state) {
          if (state is WordListLoaded) {
            return Column(
              children: [
                _buildFilterBar(state.filterMode),
                if (state.words.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No hay palabras en esta sección.'),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<WordListBloc>()
                            .add(const RefreshWordsEvent());
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: state.words.length +
                            (state.hasMorePages ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.words.length) {
                            return _buildLoadingIndicator();
                          }

                          final word = state.words[index];
                          return WordCard(
                            word: word,
                            onSpeak: () => speakf(word.word),
                            onTapImage: () =>
                                _navigateToWordDetail(word),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
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
