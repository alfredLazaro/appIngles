import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/domain/repositories/flashcard_repository.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Práctica (${_currentIndex + 1}/${widget.words.length})'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${((_currentIndex + 1) / widget.words.length * 100).toInt()}%',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Barra de progreso
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.words.length,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),

          // ✅ PageView con flashcards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // ✅ Solo con botones
              itemCount: widget.words.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final word = widget.words[index];
                final images = widget.imagesMap[word.id] ?? [];

                return _FlashcardPageItem(
                  word: word,
                  images: images,
                  onLearnedUpdated: (learnCount) {
                    setState(() {
                      _scores[word.id] = learnCount;
                    });
                  },
                );
              },
            ),
          ),

          // ✅ Controles de navegación
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón Anterior
                ElevatedButton.icon(
                  onPressed: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),

                // Contador
                Column(
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

                // Botón Siguiente/Finalizar
                ElevatedButton.icon(
                  onPressed: _currentIndex < widget.words.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : () => _showCompletionDialog(),
                  icon: Icon(
                    _currentIndex < widget.words.length - 1
                        ? Icons.arrow_forward
                        : Icons.check_circle,
                  ),
                  label: Text(
                    _currentIndex < widget.words.length - 1
                        ? 'Siguiente'
                        : 'Finalizar',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentIndex < widget.words.length - 1
                        ? null
                        : Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
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
      builder: (dialogContext) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration, color: Colors.amber, size: 30),
                  const SizedBox(width: 8),
                  const Text(
                    '¡Práctica completada!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Contenido
              Text(
                'Has practicado $totalWords palabras.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Caja de palabras aprendidas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$learnedCount palabras marcadas como aprendidas',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // Cerrar dialog
                        Navigator.pop(context); // Volver
                      },
                      child: const Text('Finalizar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        setState(() {
                          _currentIndex = 0;
                          _scores.clear();
                          _pageController.jumpToPage(0);
                        });
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Repetir'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Widget individual para cada flashcard con su propio BLoC
class _FlashcardPageItem extends StatelessWidget {
  final FlashcardWord word;
  final List<FlashcardImage> images;
  final Function(int) onLearnedUpdated;

  const _FlashcardPageItem({
    required this.word,
    required this.images,
    required this.onLearnedUpdated,
  });

  @override
  Widget build(BuildContext context) {
    //log.d('Word: ${word.word}, Images recibidas: ${images.length}');
    return BlocProvider(
      create: (context) {
        final ttsService = TtsService();
        final wordDao = WordDao();
        final wordRepository = FlashcardRepository(wordDao: wordDao);
        final bloc = FlashcardBloc(
          validateWordAnswer: ValidateWordAnswer(),
          speakText: SpeakText(ttsService),
          wordRepository: wordRepository,
        );

        // ✅ Emitir estado inicial
        return bloc
          ..emit(FlashcardLoaded(
            word: word,
            images: images,
            showFront: true,
            learnCount: word.learnCount,
          ));
      },
      child: BlocListener<FlashcardBloc, FlashcardState>(
        listener: (context, state) {
          // ✅ Escuchar validación de respuesta
          if (state is FlashcardAnswerValidated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isCorrect ? '¡Correcto! ✅' : 'Incorrecto ❌',
                ),
                backgroundColor: state.isCorrect ? Colors.green : Colors.red,
                duration: const Duration(seconds: 1),
              ),
            );
          }

          // ✅ Actualizar contador cuando cambie learnCount
          if (state is FlashcardLoaded) {
            onLearnedUpdated(state.learnCount);
          }
        },
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: EnglishFlashCard(),
        ),
      ),
    );
  }
}
