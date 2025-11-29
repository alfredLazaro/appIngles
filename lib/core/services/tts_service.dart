import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

/// Servicio de Text-to-Speech reutilizable
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final Logger _logger = Logger();

  Future<void> speak(
    String text, {
    String language = 'en-US',
    double pitch = 1.0,
    double speechRate = 0.5,
  }) async {
    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.speak(text);
    } catch (e) {
      _logger.e('Error al reproducir texto: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
