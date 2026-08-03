import 'package:first_app/domain/services/tts_service_interface.dart';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:audioplayers/audioplayers.dart';
class EdgeTtsService implements ITtsService {
  EdgeTtsService()
      : _tts = FlutterEdgeTts(voice: _voiceForLocale['en-US']!),
        _player = AudioPlayer();

  final FlutterEdgeTts _tts;
  final AudioPlayer _player;

  EdgeTtsProsody _prosody =
      const EdgeTtsProsody(rate: '1.0', pitch: '+0%', volume: '100');

  static const _voiceForLocale = {
    'en-US': 'en-US-AriaNeural',
    'en-GB': 'en-GB-SoniaNeural',
  };

  @override
  Future<void> initialize({
    String language = 'en-US',
    double pitch = 1.0,
    double speechRate = 0.5,
    double volume = 1.0,
  }) async {
    // flutter_tts: speechRate 0.0-1.0 (0.5 = normal), pitch 0.5-2.0 (1.0 = normal)
    // Edge SSML: rate como multiplicador, pitch como % relativo
    final pitchPercent = ((pitch - 1.0) * 100).round();
    _prosody = EdgeTtsProsody(
      rate: (speechRate / 0.5).toStringAsFixed(2),
      pitch: '${pitchPercent >= 0 ? '+' : ''}$pitchPercent%',
      volume: (volume * 100).round().toString(),
    );
    await setLanguage(language);
  }

  @override
  Future<void> speak(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    final result = await _tts.synthesize(clean, prosody: _prosody);
    await _player.stop();
    await _player.play(BytesSource(result.audioBytes));
  }

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<bool> get isSpeaking async => _player.state == PlayerState.playing;

  @override
  Future<void> setLanguage(String language) async {
    final voice = _voiceForLocale[language] ?? _voiceForLocale['en-US']!;
    _tts.updateConfig(_tts.config.copyWith(voice: voice, voiceLocale: language));
  }

  @override
  void dispose() {
    _tts.close();
    _player.dispose();
  }
}