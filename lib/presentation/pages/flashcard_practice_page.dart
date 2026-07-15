import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/bloc/practice/practice_event.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:first_app/presentation/widgets/controlers/page_navegation_controls.dart';
import 'package:first_app/presentation/widgets/feedback_overlay.dart';
import 'package:first_app/presentation/widgets/practice_results_widget.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/presentation/widgets/flashcard/flashcard_word.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'package:first_app/domain/services/tts_service_interface.dart';
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
    this.batchSize = AppLayout.flashcardBatchSize,
  });

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> {
  late final FlashcardBloc _bloc;
  bool? _lastIsAnswerCorrect;
  bool _feedbackDismissed = false;
  bool _precacheStarted = false;
  bool _precacheComplete = false;
  final Set<int> _precachedWordIds = {};

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

    sl<ITtsService>().initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precacheStarted) {
      _precacheStarted = true;
      _precacheFirstBatch().then((_) {
        if (mounted) setState(() => _precacheComplete = true);
        _precacheRemainingInBackground();
      }).catchError((_) {
        if (mounted) setState(() => _precacheComplete = true);
        _precacheRemainingInBackground();
      });
    }
  }

  Future<void> _precacheFirstBatch() async {
    final futures = <Future<void>>[];
    final firstWords = widget.words.take(widget.batchSize);
    for (final word in firstWords) {
      _precachedWordIds.add(word.id);
      for (final img in (widget.imagesMap[word.id] ?? [])) {
        futures.add(
          precacheImage(NetworkImage(img.url), context).catchError((_) {}),
        );
      }
    }
    await Future.wait(futures);
  }

  void _precacheRemainingInBackground() {
    final ctx = context;
    final remaining = widget.words
        .skip(widget.batchSize)
        .where((w) => !_precachedWordIds.contains(w.id))
        .toList();

    void processChunk(int index) {
      if (!mounted || index >= remaining.length) return;
      final chunk =
          remaining.sublist(index, (index + 3).clamp(0, remaining.length));
      for (final word in chunk) {
        _precachedWordIds.add(word.id);
        for (final img in (widget.imagesMap[word.id] ?? [])) {
          precacheImage(NetworkImage(img.url), ctx);
        }
      }
      Timer(const Duration(milliseconds: 300), () => processChunk(index + 3));
    }

    processChunk(0);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _submitResult(Map<int, int> scores) {
    final result = PracticeResult(
      type: PracticeType.flashcard,
      learnCountUpdates: scores,
      totalItems: widget.words.length,
      correctItems: scores.values.where((s) => s > 0).length,
    );

    context.read<PracticeBloc>().add(FinishPracticeEvent(result));
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
      child: BlocConsumer<FlashcardBloc, FlashcardState>(
        listener: (context, state) {
          if (state is FlashcardCompleted) {
            _submitResult(state.scores);
          } else if (state is FlashcardLoaded &&
              state.isAnswerCorrect != _lastIsAnswerCorrect) {
            _lastIsAnswerCorrect = state.isAnswerCorrect;
            if (state.isAnswerCorrect != null) {
              setState(() => _feedbackDismissed = false);
            }
          }
        },
        builder: (context, state) {
          if (state is FlashcardCompleted) {
            return PracticeResultsWidget(
              practiceType: PracticeType.flashcard,
              totalItems: widget.words.length,
              correctItems: state.scores.values.where((s) => s > 0).length,
              words: widget.words,
              learnCountUpdates: state.scores,
              onFinish: () => Navigator.pop(context),
              accentColor: Theme.of(context).colorScheme.secondary,
            );
          }

          if (state is! FlashcardLoaded || !_precacheComplete) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final currentMode = state.mode;
          final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

          if (state.isAnswerCorrect != _lastIsAnswerCorrect) {
            _lastIsAnswerCorrect = state.isAnswerCorrect;
            if (state.isAnswerCorrect != null) {
              _feedbackDismissed = false;
            }
          }

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
            body: Stack(
              children: [
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: (state.currentIndex + 1) / state.sessions.length,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _getModeColor(currentMode)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildFlashcard(state),
                      ),
                    ),
                    if (!keyboardOpen && state.mode == FlashcardMode.learn)
                      PageNavigationControls(
                        currentIndex: state.currentIndex,
                        totalPages: state.sessions.length,
                        onPrevious: () => _bloc.add(PreviousFlashcard()),
                        onNext: () => _bloc.add(NextFlashcard()),
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
                          ],
                        ),
                      ),
                  ],
                ),
                if (state.isAnswerCorrect != null && !_feedbackDismissed)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: FeedbackOverlay(
                      text:
                          state.isAnswerCorrect! ? '¡Correcto!' : 'Incorrecto',
                      isCorrect: state.isAnswerCorrect!,
                      displayDuration: const Duration(milliseconds: 800),
                      onDismiss: () =>
                          setState(() => _feedbackDismissed = true),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
