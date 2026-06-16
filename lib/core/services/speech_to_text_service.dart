import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';
import 'package:first_app/domain/services/speech_to_text_interface.dart';

/// Servicio reutilizable de voz a texto
class SpeechToTextService implements ISpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final Logger _logger = Logger();
  bool _isListening = false;

  @override
  bool get isListening => _isListening;

  @override
  Future<void> startListening({
    required Function(String) onResult,
  }) async {
    if (_isListening) return;

    bool available = await _speech.initialize(
      onStatus: (status) => _logger.d('Speech status: $status'),
      onError: (error) => _logger.e('Speech error: $error'),
    );

    if (available) {
      _isListening = true;
      await _speech.listen(
        onResult: (result) => onResult(result.recognizedWords),
      );
    }
  }

  @override
  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;
    await _speech.stop();
  }

  @override
  void dispose() {
    _speech.cancel();
  }
}
