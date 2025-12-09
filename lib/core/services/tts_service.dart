import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

/// Servicio de Text-to-Speech reutilizable (Singleton)
class TtsService {
  // Singleton pattern
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final Logger _logger = Logger();
  bool _isInitialized = false;

  /// Inicializa el servicio TTS con configuración por defecto
  Future<void> initialize({
    String language = 'en-US',
    double pitch = 1.0,
    double speechRate = 0.5,
    double volume = 1.0,
  }) async {
    if (_isInitialized) {
      //_logger.i('TTS ya está inicializado');
      return;
    }

    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.setVolume(volume);

      _isInitialized = true;
    } catch (e) {
      _logger.e('Error al inicializar TTS: $e');
      _isInitialized = false;
    }
  }

  /// Reproduce el texto dado
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      _logger.w('TTS no inicializado, inicializando ahora...');
      await initialize();
    }

    if (_isInitialized) {
      try {
        await _flutterTts.speak(text);
      } catch (e) {
        _logger.e('Error al reproducir texto: $e');
      }
    } else {
      _logger.e('No se pudo inicializar TTS para hablar');
    }
  }

  /// Detiene la reproducción actual
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      _logger.e('Error al detener TTS: $e');
    }
  }

  /// Verifica si el TTS está hablando actualmente
  Future<bool> get isSpeaking async {
    try {
      final speaking = await _flutterTts.awaitSpeakCompletion(false);
      return speaking ?? false;
    } catch (e) {
      _logger.e('Error al verificar estado de TTS: $e');
      return false;
    }
  }

  /// Cambia el idioma del TTS
  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
      _logger.i('Idioma cambiado a: $language');
    } catch (e) {
      _logger.e('Error al cambiar idioma: $e');
    }
  }

  /// Limpia recursos (llamar cuando la app se cierre)
  void dispose() {
    _flutterTts.stop();
    _isInitialized = false;
  }
}
