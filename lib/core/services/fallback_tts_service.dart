
import 'package:first_app/core/services/connectivity_service.dart';
import 'package:first_app/core/services/edge_tts_service.dart';
import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/domain/services/tts_service_interface.dart';
import 'package:logger/logger.dart';

class FallbackTtsService implements ITtsService {
  FallbackTtsService({
    ITtsService? primary,
    ITtsService? fallback,
    ConnectivityService? connectivity,
    this.primaryTimeout = const Duration(milliseconds: 1800),
    this.retryAfter = const Duration(seconds: 30),
  })  : _primary = primary ?? EdgeTtsService(),
        _fallback = fallback ?? TtsService(),
        _connectivity = connectivity;

  final Logger _logger = Logger();
  final ITtsService _primary;
  final ITtsService _fallback;
  final ConnectivityService? _connectivity;
  final Duration primaryTimeout;
  final Duration retryAfter;

  static const _probeTimeout = Duration(seconds: 1);

  DateTime? _primaryDownSince;
  bool _usingFallback = false;

  bool get _shouldSkipPrimary {
    final downSince = _primaryDownSince;
    return downSince != null &&
        DateTime.now().difference(downSince) < retryAfter;
  }

  Future<bool> get _isOnline async {
    final connectivity = _connectivity;
    if (connectivity == null) return true;
    return connectivity
        .hasInternet()
        .timeout(_probeTimeout, onTimeout: () => true);
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

    var skipPrimary = _shouldSkipPrimary;
    if (!skipPrimary && !await _isOnline) {
      _primaryDownSince = DateTime.now();
      skipPrimary = true;
    }

    if (!skipPrimary) {
      try {
        _logger.i('TTS -> EdgeTtsService (primario)');
        await _primary.speak(clean).timeout(primaryTimeout);
        _primaryDownSince = null;
        _usingFallback = false;
        return;
      } catch (_) {
        _primaryDownSince = DateTime.now();
      }
    }

    _usingFallback = true;
    _logger.i('TTS -> TtsService (fallback)');
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