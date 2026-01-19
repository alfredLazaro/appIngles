import 'package:first_app/data/datasources/local/word_dao.dart';
import 'package:first_app/domain/repositories/flashcard_repository.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/widgets/controlers/page_navegation_controls.dart';
import 'package:first_app/presentation/widgets/dialogs/completion_dialog.dart';
import 'package:first_app/presentation/widgets/flashcard/flashcard_word.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'package:first_app/presentation/widgets/flashcard/english_flashcard.dart';
import 'package:logger/logger.dart';

Logger log = Logger();

enum FlashcardMode { learn, test }

class FlashcardSession {
  final FlashcardWord word;
  final FlashcardMode mode;
  final int originalIndex;

  FlashcardSession({
    required this.word,
    required this.mode,
    required this.originalIndex,
  });
}

class FlashcardPracticePage extends StatefulWidget {
  final List<FlashcardWord> words;
  final Map<int, List<FlashcardImage>> imagesMap;
  final int batchSize; // Number of words to learn before testing

  const FlashcardPracticePage({
    super.key,
    required this.words,
    required this.imagesMap,
    this.batchSize = 3, // Default: learn 3, then test 3
  });

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<int, int> _scores = {};
  late final Map<int, FlashcardBloc> _flashcardBlocs;
  late final List<FlashcardSession> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = _generateSessions();
    _flashcardBlocs = {
      for (var word in widget.words) word.id: _createBlocForWord(word)
    };
  }

  /// Generates the learning sequence: Learn batch → Test batch → Learn next batch → Test next batch
  List<FlashcardSession> _generateSessions() {
    final sessions = <FlashcardSession>[];
    final batchSize = widget.batchSize;

    // Split words into batches
    for (int i = 0; i < widget.words.length; i += batchSize) {
      final end = (i + batchSize < widget.words.length)
          ? i + batchSize
          : widget.words.length;
      final batch = widget.words.sublist(i, end);

      // First, add LEARN mode for this batch
      for (int j = 0; j < batch.length; j++) {
        sessions.add(FlashcardSession(
          word: batch[j],
          mode: FlashcardMode.learn,
          originalIndex: i + j,
        ));
      }

      // Then, add TEST mode for the same batch
      for (int j = 0; j < batch.length; j++) {
        sessions.add(FlashcardSession(
          word: batch[j],
          mode: FlashcardMode.test,
          originalIndex: i + j,
        ));
      }
    }

    return sessions;
  }

  FlashcardBloc _createBlocForWord(FlashcardWord word) {
    final ttsService = TtsService();
    final wordDao = WordDao();
    final wordRepository = FlashcardRepository(wordDao: wordDao);
    final images = widget.imagesMap[word.id] ?? [];

    final initialState = FlashcardLoaded(
      word: word,
      images: images,
      showFront: false,
      learnCount: word.learnCount,
    );

    return FlashcardBloc(
      validateWordAnswer: ValidateWordAnswer(),
      speakText: SpeakText(ttsService),
      wordRepository: wordRepository,
      initialState: initialState,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var bloc in _flashcardBlocs.values) {
      bloc.close();
    }
    super.dispose();
  }

  Widget _buildFlashcard(FlashcardSession session, FlashcardBloc bloc) {
    return BlocBuilder<FlashcardBloc, FlashcardState>(
      builder: (context, state) {
        if (state is FlashcardLoaded) {
          if (session.mode == FlashcardMode.learn) {
            // Simple flashcard for learning
            return WordFlashcard(
              word: state.word,
              images: state.images,
              backgroundColor: Colors.deepPurple,
              textColor: Colors.white,
            );
          }
        }
        // Interactive flashcard for testing
        return const EnglishFlashCard();
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final currentSession = _sessions[_currentIndex];
    final currentMode = currentSession.mode;

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
                '${((_currentIndex + 1) / _sessions.length * 100).toInt()}%',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar with mode color
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _sessions.length,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor:
                AlwaysStoppedAnimation<Color>(_getModeColor(currentMode)),
          ),

          // Mode indicator banner
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

          // PageView with flashcards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _sessions.length,
              physics: isKeyboardVisible
                  ? const NeverScrollableScrollPhysics()
                  : null,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final bloc = _flashcardBlocs[session.word.id]!;

                return BlocProvider<FlashcardBloc>.value(
                  value: bloc,
                  child: BlocListener<FlashcardBloc, FlashcardState>(
                    listener: (context, state) {
                      // Only show validation feedback in TEST mode
                      if (session.mode == FlashcardMode.test &&
                          state is FlashcardAnswerValidated) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                              SnackBar(
                                content: Text(
                                  state.isCorrect
                                      ? '¡Correcto! ✅'
                                      : 'Incorrecto ❌',
                                ),
                                backgroundColor:
                                    state.isCorrect ? Colors.green : Colors.red,
                                duration: const Duration(seconds: 1),
                              ),
                            )
                            .closed
                            .then((_) {
                          context.read<FlashcardBloc>().add(FlipFlashcard());
                        });
                      }

                      if (state is FlashcardLoaded) {
                        setState(() {
                          _scores[session.word.id] = state.learnCount;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildFlashcard(session, bloc),
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation controls
          PageNavigationControls(
            currentIndex: _currentIndex,
            totalPages: _sessions.length,
            onPrevious: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            onNext: _currentIndex < _sessions.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : () => _showCompletionDialog(),
            centerWidget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_currentIndex + 1} / ${_sessions.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Palabra ${currentSession.originalIndex + 1}/${widget.words.length}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                if (_scores.isNotEmpty)
                  Text(
                    '${_scores.values.where((s) => s > 0).length} aprendidas',
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
  }

  void _showCompletionDialog() {
    final learnedCount = _scores.values.where((s) => s > 0).length;
    final totalWords = widget.words.length;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CompletionDialog(
        totalItems: totalWords,
        learnedCount: learnedCount,
        itemName: 'palabras',
        onFinish: () {
          Navigator.pop(dialogContext);
          Navigator.pop(context);
        },
        onRepeat: () {
          Navigator.pop(dialogContext);
          setState(() {
            _currentIndex = 0;
            _scores.clear();
            _pageController.jumpToPage(0);
          });
        },
        primaryColor: Theme.of(dialogContext).colorScheme.secondary,
      ),
    );
  }
}
