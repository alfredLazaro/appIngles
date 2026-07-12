import 'package:first_app/domain/services/tts_service_interface.dart';

/// Caso de uso: Reproducir texto en inglés
class SpeakText {
  final ITtsService _ttsService;

  SpeakText(this._ttsService);

  Future<void> call(String text) async {
    await _ttsService.speak(text);
  }
}
