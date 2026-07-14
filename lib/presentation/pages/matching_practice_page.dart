import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/bloc/practice/practice_event.dart';
import 'package:first_app/presentation/bloc/matching/matching_bloc.dart';
import 'package:first_app/presentation/bloc/matching/matching_event.dart';
import 'package:first_app/presentation/bloc/matching/matching_state.dart';
import 'package:first_app/presentation/widgets/matching_tile.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:logger/logger.dart';

class MatchingPracticePage extends StatefulWidget {
  final MatchingPracticeData data;
  final bool isDefinitionMode;

  const MatchingPracticePage({
    super.key,
    required this.data,
    this.isDefinitionMode = false,
  });

  @override
  State<MatchingPracticePage> createState() => _MatchingPracticePageState();
}

class _MatchingPracticePageState extends State<MatchingPracticePage> {
  bool _resultSubmitted = false;
  Logger l = Logger();

  int? _pendingLeftIndex;
  int? _pendingRightIndex;
  ({int left, int right})? _shakingPair;
  Timer? _shakingTimer;

  final Set<int> _fadingOut = {};
  final Map<int, Timer> _fadeTimers = {};
  MatchingRoundReady? _lastRoundState;

  int get _totalPairs => widget.data.rounds.fold<int>(
        0,
        (sum, r) => sum + r.words.length,
      );

  @override
  void dispose() {
    _shakingTimer?.cancel();
    for (final t in _fadeTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  void _clearRoundState() {
    for (final t in _fadeTimers.values) {
      t.cancel();
    }
    _fadingOut.clear();
    _fadeTimers.clear();
    _shakingPair = null;
    _shakingTimer?.cancel();
    _pendingLeftIndex = null;
    _pendingRightIndex = null;
  }

  void _submitResult(MatchingCompleted state) {
    if (_resultSubmitted) return;
    _resultSubmitted = true;

    final result = PracticeResult(
      type: widget.isDefinitionMode
          ? PracticeType.matchingDefinition
          : PracticeType.matching,
      learnCountUpdates: state.learnCountUpdates,
      totalItems: _totalPairs,
      correctItems: state.totalCorrect,
    );

    context.read<PracticeBloc>().add(FinishPracticeEvent(result));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = MatchingBloc();
        bloc.add(InitializeMatching(rounds: widget.data.rounds));
        return bloc;
      },
      child: BlocConsumer<MatchingBloc, MatchingState>(
        listener: (context, state) {
          if (state is MatchingCompleted) {
            _submitResult(state);
          }
        },
        builder: (context, state) {
          if (state is MatchingCompleted) {
            return _buildResults(context, state);
          }
          if (state is MatchingRoundReady) {
            return _buildRound(context, state);
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildResults(BuildContext context, MatchingCompleted state) {
    final percentage =
        _totalPairs == 0 ? 0 : (state.totalCorrect / _totalPairs * 100);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emparejar - Resultados'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 80,
                color: state.totalCorrect == _totalPairs
                    ? Colors.amber
                    : Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                state.totalCorrect == _totalPairs
                    ? '¡Perfecto!'
                    : 'Práctica completada',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${state.totalCorrect} de $_totalPairs aciertos',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: state.totalCorrect == _totalPairs
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRound(BuildContext context, MatchingRoundReady state) {
    if (state.roundIndex != _lastRoundState?.roundIndex) {
      _clearRoundState();
    }

    if (state.lastAttemptCorrect == false && _shakingPair == null) {
      if (_pendingLeftIndex != null && _pendingRightIndex != null) {
        _shakingPair =
            (left: _pendingLeftIndex!, right: _pendingRightIndex!);
        _shakingTimer?.cancel();
        _shakingTimer = Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() => _shakingPair = null);
          }
        });
      }
    }

    _fadeTimers.removeWhere((key, timer) {
      if (!state.matchedWordIndices.contains(key)) {
        timer.cancel();
        _fadingOut.remove(key);
        return true;
      }
      return false;
    });

    for (final idx in state.matchedWordIndices) {
      if (!_fadeTimers.containsKey(idx) && !_fadingOut.contains(idx)) {
        _fadeTimers[idx] = Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() => _fadingOut.add(idx));
          }
        });
      }
    }

    _lastRoundState = state;

    final isRoundComplete =
        state.matchedWordIndices.length == state.round.words.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F8),
      appBar: AppBar(
        title: Text(
          'Ronda ${state.roundIndex + 1} de ${state.totalRounds}',
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${state.totalCorrect}✓',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF22c55e),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(state),
          if (state.lastAttemptCorrect != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: state.lastAttemptCorrect!
                  ? const Color(0xFF6BFE9C).withValues(alpha: 0.3)
                  : const Color(0xFFFFDAD6),
              child: Center(
                child: Text(
                  state.lastAttemptCorrect!
                      ? '¡Correcto!'
                      : 'Incorrecto, intenta de nuevo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: state.lastAttemptCorrect!
                        ? const Color(0xFF006934)
                        : const Color(0xFFBA1A1A),
                  ),
                ),
              ),
            ),
          Expanded(
            child: widget.isDefinitionMode
                ? _buildDefinitionMode(context, state)
                : _buildTranslationMode(context, state),
          ),
          if (isRoundComplete)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF413FE6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _clearRoundState();
                    context.read<MatchingBloc>().add(NextMatchingRound());
                  },
                  child: Text(
                    state.roundIndex + 1 < state.totalRounds
                        ? 'Siguiente ronda'
                        : 'Ver resultados',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(MatchingRoundReady state) {
    final total = state.round.words.length;
    final matched = state.matchedWordIndices.length;
    final progress = total == 0 ? 0.0 : matched / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Progress',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF767587),
                      fontFamily: 'Nunito Sans',
                    ),
                  ),
                  Text(
                    'Round ${state.roundIndex + 1} of ${state.totalRounds}',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF767587),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                '$matched/$total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF22c55e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              height: 12,
              width: double.infinity,
              color: const Color(0xFFE0E0FF),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF22c55e),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9999),
                      bottomLeft: Radius.circular(9999),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationMode(BuildContext context, MatchingRoundReady state) {
    return Row(
      children: [
        Expanded(
          child: _buildColumn(
            title: 'Palabras',
            items: List.generate(
              state.round.words.length,
              (i) => AnimatedOpacity(
                opacity: _fadingOut.contains(i) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: MatchingTile(
                  text: state.round.words[i].word,
                  isSelected: state.selectedLeftIndex == i,
                  isMatched: state.matchedWordIndices.contains(i),
                  isCorrect: state.matchedWordIndices.contains(i)
                      ? true
                      : null,
                  showShake:
                      _shakingPair != null && _shakingPair!.left == i,
                  onTap: () {
                    _pendingLeftIndex = i;
                    context
                        .read<MatchingBloc>()
                        .add(SelectLeftTile(wordIndex: i));
                  },
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildColumn(
            title: 'Traducciones',
            items: List.generate(
              state.round.translations.length,
              (i) => AnimatedOpacity(
                opacity: _fadingOut.contains(i) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: MatchingTile(
                  text: state.round.translations[i].wordTranslate,
                  isSelected: state.selectedRightIndex == i,
                  isMatched:
                      state.matchedTranslationIndices.contains(i),
                  isCorrect:
                      state.matchedTranslationIndices.contains(i)
                          ? true
                          : null,
                  showShake:
                      _shakingPair != null && _shakingPair!.right == i,
                  onTap: () {
                    _pendingRightIndex = i;
                    context
                        .read<MatchingBloc>()
                        .add(SelectRightTile(translationIndex: i));
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefinitionMode(BuildContext context, MatchingRoundReady state) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  'Palabras',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        state.round.words.length,
                        (i) => AnimatedOpacity(
                          opacity: _fadingOut.contains(i) ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: MatchingTile(
                            text: state.round.words[i].word,
                            shrinkWrap: true,
                            isSelected:
                                state.selectedLeftIndex == i,
                            isMatched:
                                state.matchedWordIndices.contains(i),
                            isCorrect: state
                                    .matchedWordIndices.contains(i)
                                ? true
                                : null,
                            showShake: _shakingPair != null &&
                                _shakingPair!.left == i,
                            onTap: () {
                              _pendingLeftIndex = i;
                              context
                                  .read<MatchingBloc>()
                                  .add(SelectLeftTile(
                                      wordIndex: i));
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildColumn(
            title: 'Definiciones',
            items: List.generate(
              state.round.definitions!.length,
              (i) => AnimatedOpacity(
                opacity: _fadingOut.contains(i) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: MatchingTile(
                  text: state.round.definitions![i],
                  isSelected: state.selectedRightIndex == i,
                  isMatched:
                      state.matchedTranslationIndices.contains(i),
                  isCorrect:
                      state.matchedTranslationIndices.contains(i)
                          ? true
                          : null,
                  showShake: _shakingPair != null &&
                      _shakingPair!.right == i,
                  onTap: () {
                    _pendingRightIndex = i;
                    context
                        .read<MatchingBloc>()
                        .add(SelectRightTile(
                            translationIndex: i));
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumn({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF464556),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: items,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
