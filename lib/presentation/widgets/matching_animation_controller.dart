import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:first_app/presentation/bloc/matching/matching_state.dart';

class MatchingAnimationController extends ChangeNotifier {
  ({int left, int right})? shakingPair;
  final Set<int> fadingOutWords = {};
  final Set<int> fadingOutTranslations = {};

  final Map<int, Timer> _fadeTimersWords = {};
  final Map<int, Timer> _fadeTimersTranslations = {};
  Timer? _shakingTimer;
  MatchingRoundReady? _lastState;

  void onStateChange(
    MatchingRoundReady state,
    int? pendingLeftIndex,
    int? pendingRightIndex,
  ) {
    final roundChanged = state.roundIndex != _lastState?.roundIndex;
    if (roundChanged) _reset();

    _syncFade(state.matchedWordIndices, _fadeTimersWords, fadingOutWords);
    _syncFade(state.matchedTranslationIndices, _fadeTimersTranslations,
        fadingOutTranslations);

    if (state.lastAttemptCorrect == false &&
        shakingPair == null &&
        pendingLeftIndex != null &&
        pendingRightIndex != null) {
      _startShake(pendingLeftIndex, pendingRightIndex);
    }

    _lastState = state;
    notifyListeners();
  }

  void _syncFade(
    Set<int> matched,
    Map<int, Timer> timers,
    Set<int> fadingOut,
  ) {
    timers.removeWhere((key, timer) {
      if (!matched.contains(key)) {
        timer.cancel();
        fadingOut.remove(key);
        return true;
      }
      return false;
    });
    for (final idx in matched) {
      if (!timers.containsKey(idx) && !fadingOut.contains(idx)) {
        timers[idx] = Timer(const Duration(milliseconds: 800), () {
          fadingOut.add(idx);
          notifyListeners();
        });
      }
    }
  }

  void _startShake(int left, int right) {
    shakingPair = (left: left, right: right);
    notifyListeners();
    _shakingTimer?.cancel();
    _shakingTimer = Timer(const Duration(milliseconds: 800), () {
      shakingPair = null;
      notifyListeners();
    });
  }

  void _reset() {
    for (final t in _fadeTimersWords.values) {
      t.cancel();
    }
    for (final t in _fadeTimersTranslations.values) {
      t.cancel();
    }
    _fadeTimersWords.clear();
    _fadeTimersTranslations.clear();
    fadingOutWords.clear();
    fadingOutTranslations.clear();
    _shakingTimer?.cancel();
    shakingPair = null;
  }

  @override
  void dispose() {
    _reset();
    super.dispose();
  }
}
