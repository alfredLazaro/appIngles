import 'package:first_app/data/datasources/local/word_dao.dart';
import 'package:first_app/domain/repositories/flashcard_repository.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:first_app/presentation/widgets/controlers/page_navegation_controls.dart';
import 'package:first_app/presentation/widgets/dialogs/completion_dialog.dart';
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

class FlashcardPracticePage extends StatefulWidget {
  final List<FlashcardWord> words;
  final Map<int, List<FlashcardImage>> imagesMap; // wordId → List<Images>

  const FlashcardPracticePage({
    super.key,
    required this.words,
    required this.imagesMap,
  });

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<int, int> _scores = {}; // wordId → score (learned count)
  late final Map<int, FlashcardBloc> _flashcardBlocs;

  @override
  void initState() {
    super.initState();
    // Initialize all BLoCs once
    _flashcardBlocs = {
      for (var word in widget.words) word.id: _createBlocForWord(word)
    };
  }

  FlashcardBloc _createBlocForWord(FlashcardWord word) {
    final ttsService = TtsService();
    final wordDao = WordDao();
    final wordRepository = FlashcardRepository(wordDao: wordDao);
    final images = widget.imagesMap[word.id] ?? [];

    final initialState = FlashcardLoaded(
      word: word,
      images: images,
      showFront: true,
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
    // Dispose all BLoCs
    for (var bloc in _flashcardBlocs.values) {
      bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: isKeyboardVisible
          ? null
          : AppBar(
              title: Text(
                  'Práctica (${_currentIndex + 1}/${widget.words.length})'),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      '${((_currentIndex + 1) / widget.words.length * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
      body: Column(
        children: [
          // Barra de progreso
          if (!isKeyboardVisible)
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.words.length,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),

          // PageView con flashcards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.words.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final word = widget.words[index];
                final images = widget.imagesMap[word.id] ?? [];
                final bloc = _flashcardBlocs[word.id]!;

                // Use BlocProvider.value instead of BlocProvider
                return BlocProvider<FlashcardBloc>.value(
                  value: bloc,
                  child: BlocListener<FlashcardBloc, FlashcardState>(
                    listener: (context, state) {
                      if (state is FlashcardAnswerValidated) {
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
                          _scores[word.id] = state.learnCount;
                        });
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: EnglishFlashCard(),
                    ),
                  ),
                );
              },
            ),
          ),

          // Controles de navegación (ahora reutilizable)
          if (!isKeyboardVisible)
            PageNavigationControls(
              currentIndex: _currentIndex,
              totalPages: widget.words.length,
              onPrevious: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onNext: _currentIndex < widget.words.length - 1
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
                    '${_currentIndex + 1} / ${widget.words.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
          /* Navigator.popUntil(context, (route) {
            // This will pop until we reach the PracticeSelectionPage
            return route.settings.name == '/practice-selection' ||
                route.isFirst;
          }); */
          // OR if you want to go back to the PracticeSelectionPage directly:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const PracticeSelectionPage()), //solo la pagina sin la barra de navegacion como si fuera la unica
            (route) => false,
          );
        },
        onRepeat: () {
          Navigator.pop(dialogContext);
          setState(() {
            _currentIndex = 0;
            _scores.clear();
            _pageController.jumpToPage(0);
          });
        },
        // Opcional: personalización
        primaryColor: Theme.of(dialogContext).colorScheme.secondary,
      ),
    );
  }
}
