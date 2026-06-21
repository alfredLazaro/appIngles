import 'package:first_app/presentation/bloc/spelling/spelling_bloc.dart';
import 'package:first_app/presentation/bloc/spelling/spelling_event.dart';
import 'package:first_app/presentation/bloc/spelling/spelling_state.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/bloc/practice/practice_event.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:first_app/presentation/widgets/controlers/page_navegation_controls.dart';
import 'package:first_app/presentation/widgets/dialogs/completion_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'package:first_app/core/di/dependency_injection.dart';

class SpellingPracticePage extends StatefulWidget {
  final List<FlashcardWord> words;
  final int maxAudioPlays;

  const SpellingPracticePage({
    super.key,
    required this.words,
    this.maxAudioPlays = 0,
  });

  @override
  State<SpellingPracticePage> createState() => _SpellingPracticePageState();
}

class _SpellingPracticePageState extends State<SpellingPracticePage> {
  late final SpellingBloc _bloc;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _bloc = SpellingBloc(
      validateWordAnswer: sl<ValidateWordAnswer>(),
      speakText: sl<SpeakText>(),
    );
    _bloc.add(InitializeSpelling(
      words: widget.words,
      maxAudioPlays: widget.maxAudioPlays,
    ));
  }

  @override
  void dispose() {
    _bloc.close();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitResult(SpellingCompleted state) {
    final result = PracticeResult(
      type: PracticeType.spelling,
      learnCountUpdates: state.learnCountUpdates,
      totalItems: state.totalItems,
      correctItems: state.correctItems,
    );
    context.read<PracticeBloc>().add(FinishPracticeEvent(result));
  }

  void _showCompletionDialog(SpellingCompleted state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CompletionDialog(
        totalItems: state.totalItems,
        learnedCount: state.correctItems,
        itemName: 'palabras',
        onFinish: () {
          Navigator.pop(dialogContext);
          Navigator.pop(context);
        },
        onRepeat: () {
          Navigator.pop(dialogContext);
          _textController.clear();
          _bloc.add(InitializeSpelling(
            words: widget.words,
            maxAudioPlays: widget.maxAudioPlays,
          ));
        },
        primaryColor: Colors.orange,
      ),
    );

    _submitResult(state);
  }

  void _onNextOrFinish(SpellingLoaded state) {
    final isLast = state.currentIndex >= state.words.length - 1;

    if (state.hasSubmitted) {
      _textController.clear();
      _focusNode.requestFocus();
      if (isLast) {
        _bloc.add(const FinishSpelling());
      } else {
        _bloc.add(const NextSpellingWord());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpellingBloc>.value(
      value: _bloc,
      child: BlocListener<SpellingBloc, SpellingState>(
        listenWhen: (previous, current) => current is SpellingCompleted,
        listener: (context, state) {
          if (state is SpellingCompleted) {
            _showCompletionDialog(state);
          }
        },
        child: BlocBuilder<SpellingBloc, SpellingState>(
          builder: (context, state) {
            if (state is! SpellingLoaded) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text('Spelling'),
                backgroundColor: Colors.orange,
                actions: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        '${((state.currentIndex + 1) / state.words.length * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Column(
                children: [
                  LinearProgressIndicator(
                    value: (state.currentIndex + 1) / state.words.length,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          _buildDefinitionCard(state),
                          const SizedBox(height: 24),
                          _buildAudioButton(state),
                          if (state.maxAudioPlays > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                state.audioPlayedCount > 0
                                    ? 'Reproducido ${state.audioPlayedCount} vez/veces'
                                    : '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          _buildInputSection(state),
                          if (state.hasSubmitted && state.isCorrect != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: _buildFeedback(state),
                            ),
                        ],
                      ),
                    ),
                  ),
                  PageNavigationControls(
                    currentIndex: state.currentIndex,
                    totalPages: state.words.length,
                    onPrevious: () {
                      _textController.clear();
                      _focusNode.requestFocus();
                      _bloc.add(const PreviousSpellingWord());
                    },
                    onNext: state.hasSubmitted
                        ? () => _onNextOrFinish(state)
                        : null,
                    nextButtonColor: Colors.orange,
                    nextLabel: 'Siguiente',
                    finalLabel: 'Finalizar',
                    centerWidget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${state.currentIndex + 1} / ${state.words.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.scores.values.where((s) => s > 0).length} correctas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefinitionCard(SpellingLoaded state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.menu_book,
              size: 32,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 12),
            Text(
              'Escribe la palabra en inglés',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.currentWord.definition,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioButton(SpellingLoaded state) {
    if (state.maxAudioPlays <= 0) return const SizedBox.shrink();

    final canPlay = state.maxAudioPlays < 0 || state.audioPlayedCount < state.maxAudioPlays;

    return Center(
      child: IconButton.filled(
        onPressed: canPlay
            ? () => _bloc.add(const PlayCurrentWordAudio())
            : null,
        icon: const Icon(Icons.volume_up, size: 28),
        style: IconButton.styleFrom(
          backgroundColor: canPlay ? Colors.orange : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
        ),
        tooltip: canPlay ? 'Escuchar palabra' : 'Límite de reproducciones alcanzado',
      ),
    );
  }

  Widget _buildInputSection(SpellingLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: !state.hasSubmitted,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            hintText: 'Escribe la palabra aquí...',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
          onSubmitted: state.hasSubmitted
              ? null
              : (value) {
                  if (value.trim().isNotEmpty) {
                    _bloc.add(SubmitSpellingAnswer(value.trim()));
                  }
                },
        ),
        const SizedBox(height: 12),
        if (!state.hasSubmitted)
          ElevatedButton(
            onPressed: () {
              final text = _textController.text.trim();
              if (text.isNotEmpty) {
                _bloc.add(SubmitSpellingAnswer(text));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Comprobar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildFeedback(SpellingLoaded state) {
    final isCorrect = state.isCorrect!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? '¡Correcto!' : 'Incorrecto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                if (!isCorrect)
                  Text(
                    'Respuesta correcta: ${state.currentWord.word}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[700],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
