import 'package:flutter/material.dart';
import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/core/services/tts_service.dart';
import 'dart:math';

class SentencePracticePage extends StatefulWidget {
  final int sentenceCount;

  const SentencePracticePage({
    super.key,
    required this.sentenceCount,
  });

  @override
  State<SentencePracticePage> createState() => _SentencePracticePageState();
}

class _SentencePracticePageState extends State<SentencePracticePage> {
  final WordDao _wordDao = WordDao();
  final TtsService _ttsService = TtsService();
  final PageController _pageController = PageController();

  List<Map<String, dynamic>>? _sentences;
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSentences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSentences() async {
    try {
      final sentences =
          await _wordDao.getSentencesForPractice(widget.sentenceCount);
      setState(() {
        _sentences = sentences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Ordenar Oraciones (${_currentIndex + 1}/${_sentences?.length ?? 0})'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_sentences != null ? ((_currentIndex + 1) / _sentences!.length * 100).toInt() : 0}%',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sentences == null || _sentences!.isEmpty
              ? const Center(child: Text('No hay oraciones disponibles'))
              : Column(
                  children: [
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / _sentences!.length,
                      minHeight: 6,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sentences!.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final sentence = _sentences![index];
                          return _SentenceBuilderWidget(
                            key: ValueKey(sentence['id']),
                            sentenceId: sentence['id'],
                            originalSentence: sentence['sentence'],
                            ttsService: _ttsService,
                          );
                        },
                      ),
                    ),
                    _buildNavigationControls(),
                  ],
                ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
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
          ),
          Text(
            '${_currentIndex + 1} / ${_sentences!.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: _currentIndex < _sentences!.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : () => _showCompletionDialog(),
            icon: Icon(_currentIndex < _sentences!.length - 1
                ? Icons.arrow_forward
                : Icons.check_circle),
            label: Text(_currentIndex < _sentences!.length - 1
                ? 'Siguiente'
                : 'Finalizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _currentIndex < _sentences!.length - 1 ? null : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 30),
            SizedBox(width: 8),
            Text('¡Completado!'),
          ],
        ),
        content: Text('Has practicado ${_sentences!.length} oraciones.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Finalizar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _currentIndex = 0;
                _pageController.jumpToPage(0);
              });
            },
            icon: const Icon(Icons.replay),
            label: const Text('Repetir'),
          ),
        ],
      ),
    );
  }
}

// ✅ Widget individual para cada oración
class _SentenceBuilderWidget extends StatefulWidget {
  final int sentenceId;
  final String originalSentence;
  final TtsService ttsService;

  const _SentenceBuilderWidget({
    super.key,
    required this.sentenceId,
    required this.originalSentence,
    required this.ttsService,
  });

  @override
  State<_SentenceBuilderWidget> createState() => _SentenceBuilderWidgetState();
}

class _SentenceBuilderWidgetState extends State<_SentenceBuilderWidget> {
  late List<String> _shuffledWords;
  late List<String> _userSentence;
  bool _isCorrect = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _initializeWords();
  }

  void _initializeWords() {
    // Dividir oración en palabras
    final words = widget.originalSentence.split(' ');

    // Mezclar palabras
    _shuffledWords = List.from(words)..shuffle(Random());
    _userSentence = [];
    _isCorrect = false;
    _showResult = false;
  }

  void _checkAnswer() {
    final userSentence = _userSentence.join(' ');
    final isCorrect = userSentence.trim().toLowerCase() ==
        widget.originalSentence.trim().toLowerCase();

    setState(() {
      _isCorrect = isCorrect;
      _showResult = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? '¡Correcto! ✅' : 'Incorrecto ❌'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _reset() {
    setState(() {
      _initializeWords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            children: [
              // ✅ Botón de audio (pista)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates, color: Colors.blue),
                      const SizedBox(width: 5),
                      const Expanded(
                        child: Text(
                          'Escucha y ordena las palabras:',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 28),
                        color: Colors.blue,
                        onPressed: () {
                          widget.ttsService.speak(
                            widget.originalSentence,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Área de construcción de oración
              Container(
                width: double.infinity,
                height: 160,
                constraints: const BoxConstraints(minHeight: 120),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: _showResult
                      ? (_isCorrect ? Colors.green.shade50 : Colors.red.shade50)
                      : Colors.white,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: -6,
                      children: _userSentence.isEmpty
                          ? [
                              const Center(
                                child: Text(
                                  'Toca las palabras para formar la oración',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            ]
                          : _userSentence.asMap().entries.map((entry) {
                              return _WordChip(
                                word: entry.value,
                                color: Colors.blue,
                                onTap: () {
                                  setState(() {
                                    _shuffledWords.add(entry.value);
                                    _userSentence.removeAt(entry.key);
                                    _showResult = false;
                                  });
                                },
                              );
                            }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Palabras disponibles
              const Text(
                'Palabras disponibles:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                height: 260, // Altura máxima
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  //border: Border.all(color: Colors.grey[300]),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: -3,
                      children: _shuffledWords.map((word) {
                        return _WordChip(
                          word: word,
                          color: const Color.fromARGB(255, 40, 37, 204),
                          onTap: () {
                            setState(() {
                              _userSentence.add(word);
                              _shuffledWords.remove(word);
                              _showResult = false;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // ✅ Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reiniciar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _userSentence.isEmpty ? null : _checkAnswer,
                      icon: const Icon(Icons.check),
                      label: const Text('Verificar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // ✅ Mostrar respuesta correcta si falla
          if (_showResult && !_isCorrect)
            Positioned(
              top: 0, // lo coloca arriba
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  widget.originalSentence,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                  ),
                  textScaler: const TextScaler.linear(0.9),
                  //softWrap: true,
                  //overflow: TextOverflow.visible,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ✅ Widget de palabra clickeable
class _WordChip extends StatelessWidget {
  final String word;
  final Color color;
  final VoidCallback onTap;

  const _WordChip({
    required this.word,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          word,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
      ),
    );
  }
}
