
import 'package:first_app/core/services/edge_tts_service.dart';
import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/domain/services/tts_service_interface.dart';

class FallbackTtsService implements ITtsService {
  FallbackTtsService({
    ITtsService? primary,
    ITtsService? fallback,
    this.retryAfter = const Duration(seconds: 30),
  })  : _primary = primary ?? EdgeTtsService(),
        _fallback = fallback ?? TtsService();

  final ITtsService _primary;
  final ITtsService _fallback;
  final Duration retryAfter;

  DateTime? _primaryDownSince;
  bool _usingFallback = false;

  bool get _shouldSkipPrimary {
    final downSince = _primaryDownSince;
    return downSince != null &&
        DateTime.now().difference(downSince) < retryAfter;
  }

  @override
  Future<void> initialize({
    String language = 'en-US',
    double pitch = 1.0,
    double speechRate = 0.5,
    double volume = 1.0,
  }) async {
    // Se inicializan ambos para que el fallback quede listo
    // sin necesidad de reinicializarlo en el momento del fallo.
    await Future.wait([
      _primary.initialize(
        language: language, pitch: pitch,
        speechRate: speechRate, volume: volume,
      ),
      _fallback.initialize(
        language: language, pitch: pitch,
        speechRate: speechRate, volume: volume,
      ),
    ]);
  }

  @override
  Future<void> speak(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;

    if (!_shouldSkipPrimary) {
      try {
        await _primary.speak(clean).timeout(const Duration(seconds: 5));
        _primaryDownSince = null;
        _usingFallback = false;
        return;
      } catch (_) {
        _primaryDownSince = DateTime.now();
      }
    }

    _usingFallback = true;
    await _fallback.speak(clean);
  }

  @override
  Future<void> stop() async {
    await _primary.stop();
    await _fallback.stop();
  }

  @override
  Future<bool> get isSpeaking =>
      _usingFallback ? _fallback.isSpeaking : _primary.isSpeaking;

  @override
  Future<void> setLanguage(String language) => Future.wait([
        _primary.setLanguage(language),
        _fallback.setLanguage(language),
      ]).then((_) {});

  @override
  void dispose() {
    _primary.dispose();
    _fallback.dispose();
  }
}