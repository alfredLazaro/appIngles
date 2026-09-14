import 'dart:async';
import 'dart:typed_data';

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

  int _generation = 0;
  Completer<void>? _cancelSignal;
  StreamSubscription<EdgeTtsStreamEvent>? _activeSub;

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

    await _cancelCurrent();
    _cancelSignal = Completer<void>();
    final generation = _generation;

    final bytes = BytesBuilder(copy: false);
    final done = Completer<Uint8List>();

    late final StreamSubscription<EdgeTtsStreamEvent> sub;
    sub = _tts.synthesizeStream(clean, prosody: _prosody).listen(
      (event) {
        if (event is EdgeTtsAudioChunkEvent) {
          bytes.add(event.chunk);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!done.isCompleted) {
          done.completeError(error, stackTrace);
        }
      },
      onDone: () {
        if (done.isCompleted) return;
        final audio = bytes.takeBytes();
        if (audio.isEmpty) {
          done.completeError(
            const EdgeTtsException(
              'empty_audio',
              'No audio bytes were returned by the synthesis request.',
            ),
          );
        } else {
          done.complete(audio);
        }
      },
      cancelOnError: true,
    );
    _activeSub = sub;

    try {
      await Future.any([done.future, _cancelSignal!.future]);
      if (generation != _generation) return;
      final audio = await done.future;
      await _player.stop();
      await _player.play(BytesSource(audio));
    } on Object {
      if (generation != _generation) return;
      rethrow;
    } finally {
      if (identical(_activeSub, sub)) {
        _activeSub = null;
      }
    }
  }

  @override
  Future<void> cancelInFlight() => _cancelCurrent();

  Future<void> _cancelCurrent() async {
    _generation++;
    final signal = _cancelSignal;
    if (signal != null && !signal.isCompleted) {
      signal.complete();
    }
    final sub = _activeSub;
    if (sub != null) {
      _activeSub = null;
      await sub.cancel();
    }
    await _player.stop();
  }

  @override
  Future<void> stop() => _cancelCurrent();

  @override
  Future<bool> get isSpeaking async => _player.state == PlayerState.playing;

  @override
  Future<void> setLanguage(String language) async {
    final voice = _voiceForLocale[language] ?? _voiceForLocale['en-US']!;
    _tts.updateConfig(_tts.config.copyWith(voice: voice, voiceLocale: language));
  }

  @override
  void dispose() {
    _generation++;
    final signal = _cancelSignal;
    if (signal != null && !signal.isCompleted) {
      signal.complete();
    }
    final sub = _activeSub;
    _activeSub = null;
    sub?.cancel();
    _tts.close();
    _player.dispose();
  }
}