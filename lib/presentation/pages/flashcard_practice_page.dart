/* import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'package:first_app/data/mappers/flashcard_mapper.dart';
import 'package:first_app/data/models/pf_ing_model.dart';
import 'package:first_app/data/models/image_model.dart';
import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'package:first_app/presentation/widgets/flashcard/english_flashcard.dart';

class FlashcardPracticePage extends StatefulWidget {
  final int wordCount; // ✅ Cantidad de palabras a practicar

  const FlashcardPracticePage({
    super.key,
    required this.wordCount,
  });

  @override
  State<FlashcardPracticePage> createState() => _FlashcardPracticePageState();
}

class _FlashcardPracticePageState extends State<FlashcardPracticePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final WordDao _wordDao = WordDao();
  final ImageDao _imageDao = ImageDao();

  List<PfIng>? _words;
  Map<int, List<Image_Model>> _imagesMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    try {
      // Cargar palabras
      final words = await _wordDao.getLastPfIngBasic();
      final limitedWords = words.take(widget.wordCount).toList();

      // Cargar imágenes para cada palabra
      final Map<int, List<Image_Model>> imagesMap = {};
      for (var word in limitedWords) {
        final images = await _imageDao.getImagesByWordId(word.id!);
        imagesMap[word.id!] = images;
      }

      setState(() {
        _words = limitedWords;
        _imagesMap = imagesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando palabras: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Práctica (${_currentIndex + 1}/${_words?.length ?? 0})'),
        actions: [
          // ✅ Indicador de progreso
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_words != null ? ((_currentIndex + 1) / _words!.length * 100).toInt() : 0}%',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _words == null || _words!.isEmpty
              ? const Center(child: Text('No hay palabras para practicar'))
              : Column(
                  children: [
                    // ✅ Barra de progreso
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / _words!.length,
                      minHeight: 6,
                    ),

                    // ✅ PageView con flashcards
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _words!.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final word = _words![index];
                          final images = _imagesMap[word.id] ?? [];

                          return BlocProvider(
                            create: (context) {
                              final ttsService = TtsService();
                              final bloc = FlashcardBloc(
                                validateWordAnswer: ValidateWordAnswer(),
                                speakText: SpeakText(ttsService),
                              );

                              final wordEntity = FlashcardMapper.toEntity(word);
                              final imageEntities =
                                  FlashcardMapper.imagesToEntities(images);

                              return bloc
                                ..emit(FlashcardLoaded(
                                  word: wordEntity,
                                  images: imageEntities,
                                  showFront: true,
                                  learnCount: 0,
                                ));
                            },
                            child: BlocListener<FlashcardBloc, FlashcardState>(
                              listener: (context, state) {
                                if (state is FlashcardAnswerValidated) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        state.isCorrect
                                            ? '¡Correcto! ✅'
                                            : 'Incorrecto ❌',
                                      ),
                                      backgroundColor: state.isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: EnglishFlashCard(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ✅ Controles de navegación
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _currentIndex > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Anterior'),
                          ),
                          Text(
                            '${_currentIndex + 1} / ${_words!.length}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: _currentIndex < _words!.length - 1
                                ? () {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : () {
                                    // ✅ Última tarjeta: mostrar resumen
                                    _showCompletionDialog();
                                  },
                            icon: Icon(_currentIndex < _words!.length - 1
                                ? Icons.arrow_forward
                                : Icons.check),
                            label: Text(_currentIndex < _words!.length - 1
                                ? 'Siguiente'
                                : 'Finalizar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 ¡Práctica completada!'),
        content: Text('Has practicado ${_words!.length} palabras.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar dialog
              Navigator.pop(context); // Volver a página anterior
            },
            child: const Text('Finalizar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _pageController.jumpToPage(0);
              });
            },
            child: const Text('Repetir'),
          ),
        ],
      ),
    );
  }
}
 */
