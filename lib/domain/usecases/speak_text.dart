import 'package:first_app/core/services/tts_service.dart';

/// Caso de uso: Reproducir texto en inglés
class SpeakText {
  final TtsService _ttsService;

  SpeakText(this._ttsService);

  Future<void> call(String text) async {
    await _ttsService.speak(text);
  }
}
