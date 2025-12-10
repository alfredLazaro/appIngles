import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/presentation/widgets/WordCard.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ListaCards extends StatefulWidget {
  final List<WordWithImage> lswords;
  const ListaCards({
    super.key,
    required this.lswords,
  });

  @override
  State<ListaCards> createState() => _ListaCardState();
}

class _ListaCardState extends State<ListaCards> {
  final TtsService _ttsService = TtsService();
  final log = Logger();
  late List<WordWithImage> _lisWords;
  @override
  void initState() {
    super.initState();

    _lisWords = widget.lswords;
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize(
      language: 'en-US',
      pitch: 1.0,
      speechRate: 0.5,
    );
  }

  Future<void> speakf(String text) async {
    try {
      await _ttsService.speak(text);
    } catch (e) {
      log.e('Error al leer el texto: $e');
    }
  }

  @override
  void dispose() {
    _ttsService.stop(); // ← Detener al destruir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lisWords.isEmpty) {
      return const Center(child: Text('No hay palabras en esta sección.'));
    }
    return ListView.builder(
      itemCount: _lisWords.length,
      itemBuilder: (context, index) {
        final word = _lisWords[index];
        return WordCard(
          word: word,
          onSpeak: () => speakf(word.word),
        );
      },
    );
  }
}
