import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/bloc/practice/practice_event.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:first_app/presentation/widgets/controlers/page_navegation_controls.dart';
import 'package:first_app/presentation/widgets/dialogs/completion_dialog.dart';
import 'package:first_app/presentation/widgets/flashcard/flashcard_word.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/presentation/widgets/flashcard/english_flashcard.dart';

class FlashcardPracticePage extends StatefulWidget {
  final List<FlashcardWord> words;
  final Map<int, List<FlashcardImage>> imagesMap;
  final int batchSize;

  const FlashcardPracticePage({
    super.key,
    required this.words,
    required this.imagesMap,
    this.batchSize = 3,
  });

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> {
  late final FlashcardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FlashcardBloc(
      validateWordAnswer: sl<ValidateWordAnswer>(),
      speakText: sl<SpeakText>(),
    );
    _bloc.add(InitializeSession(
      words: widget.words,
      imagesMap: widget.imagesMap,
      batchSize: widget.batchSize,
    ));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  bool _isLastPage(FlashcardLoaded state) {
    return state.currentIndex >= state.sessions.length - 1;
  }

  void _submitResult() {
    final state = _bloc.state;
    if (state is! FlashcardLoaded) return;

    final result = PracticeResult(
      type: PracticeType.flashcard,
      learnCountUpdates: state.scores,
      totalItems: widget.words.length,
      correctItems: state.scores.values.where((s) => s > 0).length,
    );

    context.read<PracticeBloc>().add(FinishPracticeEvent(result));
  }

  void _showCompletionDialog(FlashcardLoaded state) {
    final learnedCount = state.scores.values.where((s) => s > 0).length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CompletionDialog(
        totalItems: widget.words.length,
        learnedCount: learnedCount,
        itemName: 'palabras',
        onFinish: () {
          Navigator.pop(dialogContext);
          Navigator.pop(context);
        },
        onRepeat: () {
          Navigator.pop(dialogContext);
          _bloc.add(InitializeSession(
            words: widget.words,
            imagesMap: widget.imagesMap,
            batchSize: widget.batchSize,
          ));
        },
        primaryColor: Theme.of(dialogContext).colorScheme.secondary,
      ),
    );

    _submitResult();
  }

  Color _getModeColor(FlashcardMode mode) {
    return mode == FlashcardMode.learn ? Colors.blue : Colors.green;
  }

  IconData _getModeIcon(FlashcardMode mode) {
    return mode == FlashcardMode.learn ? Icons.school : Icons.quiz;
  }

  String _getModeLabel(FlashcardMode mode) {
    return mode == FlashcardMode.learn ? 'Aprendiendo' : 'Practicando';
  }

  Widget _buildFlashcard(FlashcardLoaded state) {
    if (state.mode == FlashcardMode.learn) {
      return WordFlashcard(
        word: state.word,
        images: state.images,
        backgroundColor: Colors.deepPurple,
        textColor: Colors.white,
      );
    }
    return const EnglishFlashCard();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FlashcardBloc>.value(
      value: _bloc,
      child: BlocListener<FlashcardBloc, FlashcardState>(
        listenWhen: (previous, current) {
          if (current is! FlashcardLoaded) return false;
          return current.isAnswerCorrect != null &&
              (previous is! FlashcardLoaded || previous.isAnswerCorrect == null);
        },
        listener: (context, state) {
          if (state is! FlashcardLoaded || state.isAnswerCorrect == null) return;
          if (state.mode != FlashcardMode.test) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isAnswerCorrect!
                    ? '¡Correcto! ✅'
                    : 'Incorrecto ❌',
              ),
              backgroundColor:
                  state.isAnswerCorrect! ? Colors.green : Colors.red,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: BlocBuilder<FlashcardBloc, FlashcardState>(
          builder: (context, state) {
            if (state is! FlashcardLoaded) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final currentMode = state.mode;
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getModeIcon(currentMode), size: 20),
                    const SizedBox(width: 8),
                    Text(_getModeLabel(currentMode)),
                  ],
                ),
                backgroundColor: _getModeColor(currentMode),
                actions: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        '${((state.currentIndex + 1) / state.sessions.length * 100).toInt()}%',
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
                    value: (state.currentIndex + 1) / state.sessions.length,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getModeColor(currentMode)),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: _getModeColor(currentMode).withOpacity(0.1),
                    child: Text(
                      currentMode == FlashcardMode.learn
                          ? '📖 Modo Aprendizaje - Lee y memoriza'
                          : '✍️ Modo Práctica - ¡Demuestra lo que aprendiste!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getModeColor(currentMode),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildFlashcard(state),
                    ),
                  ),
                  PageNavigationControls(
                    currentIndex: state.currentIndex,
                    totalPages: state.sessions.length,
                    onPrevious: () => _bloc.add(PreviousFlashcard()),
                    onNext: _isLastPage(state)
                        ? () => _showCompletionDialog(state)
                        : () => _bloc.add(NextFlashcard()),
                    centerWidget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${state.currentIndex + 1} / ${state.sessions.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Palabra ${state.originalIndex + 1}/${widget.words.length}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (state.scores.isNotEmpty)
                          Text(
                            '${state.scores.values.where((s) => s > 0).length} aprendidas',
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
}