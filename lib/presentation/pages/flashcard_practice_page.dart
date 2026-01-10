import 'package:first_app/data/datasources/local/word_dao.dart';
import 'package:first_app/domain/repositories/flashcard_repository.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
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
  final Map<int, List<FlashcardImage>> imagesMap;

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
  final Map<int, int> _scores = {};
  late final Map<int, FlashcardBloc> _flashcardBlocs;

  @override
  void initState() {
    super.initState();
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
    for (var bloc in _flashcardBlocs.values) {
      bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      // FIXED: Changed to true to allow proper keyboard handling
      resizeToAvoidBottomInset: true,
      // FIXED: Always show AppBar, just adjust its height
      appBar: AppBar(
        // Hide AppBar content when keyboard is visible, but keep the AppBar widget
        toolbarHeight: isKeyboardVisible ? 0 : kToolbarHeight,
        title: isKeyboardVisible 
            ? null 
            : Text('Práctica (${_currentIndex + 1}/${widget.words.length})'),
        actions: isKeyboardVisible 
            ? null 
            : [
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
          // Progress bar
          if (!isKeyboardVisible)
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.words.length,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),

          // PageView with flashcards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.words.length,
              physics: isKeyboardVisible 
                  ? const NeverScrollableScrollPhysics() 
                  : null, // Disable swipe when keyboard is open
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final word = widget.words[index];
                final bloc = _flashcardBlocs[word.id]!;

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

          // Navigation controls
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