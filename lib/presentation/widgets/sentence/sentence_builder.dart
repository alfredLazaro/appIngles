import 'dart:math';

import 'package:first_app/core/services/tts_service.dart';
import 'package:flutter/material.dart';

// ✅ Widget individual para cada oración
class SentenceBuilderWidget extends StatefulWidget {
  final int sentenceId;
  final String originalSentence;
  final TtsService ttsService;

  const SentenceBuilderWidget({
    super.key,
    required this.sentenceId,
    required this.originalSentence,
    required this.ttsService,
  });

  @override
  State<SentenceBuilderWidget> createState() => _SentenceBuilderWidgetState();
}

class _SentenceBuilderWidgetState extends State<SentenceBuilderWidget> {
  late List<String> _shuffledWords;
    late List<bool> _wordVisibility;
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
    _shuffledWords = List.from(words)..shuffle(Random());
    _wordVisibility = List.filled(_shuffledWords.length, true);
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
                                    final originalIndex = _shuffledWords.indexOf(entry.value);
                                    if (originalIndex != -1) {
                                      _wordVisibility[originalIndex] = true;
                                    }
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
              Container(
                height: 260, // Altura máxima
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color.fromARGB(255, 46, 41, 41)),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Wrap(
                      spacing: 5,
                      runSpacing: -3,
                      children: _shuffledWords.asMap().entries.map((entry) {
                        final index = entry.key;
                        final word = entry.value;
                        
                        return Visibility(
                          visible: _wordVisibility[index], // ✅ Control de visibilidad
                          maintainSize: true,              // ✅ Mantiene el espacio
                          maintainAnimation: true,
                          maintainState: true,
                          child: _WordChip(
                            word: word,
                            color: const Color.fromARGB(255, 40, 37, 204),
                            onTap: () {
                              setState(() {
                                _userSentence.add(word);
                                _wordVisibility[index] = false; // ✅ Ocultar, no eliminar
                                _showResult = false;
                              });
                            },
                          ),
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
