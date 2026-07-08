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
  int get _totalPairs => widget.data.rounds.fold<int>(
        0,
        (sum, r) => sum + r.words.length,
      );
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
    final isRoundComplete =
        state.matchedWordIndices.length == state.round.words.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ronda ${state.roundIndex + 1} de ${state.totalRounds}'),
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
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.lastAttemptCorrect != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: state.lastAttemptCorrect!
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Center(
                child: Text(
                  state.lastAttemptCorrect!
                      ? '¡Correcto!'
                      : 'Incorrecto, intenta de nuevo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: state.lastAttemptCorrect!
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ),
          Expanded(
            child: widget.isDefinitionMode
                ? Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
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
                                      (i) => MatchingTile(
                                        text: state.round.words[i].word,
                                        shrinkWrap: true,
                                        isSelected:
                                            state.selectedLeftIndex == i,
                                        isMatched: state.matchedWordIndices
                                            .contains(i),
                                        isCorrect:
                                            state.matchedWordIndices.contains(i)
                                                ? true
                                                : null,
                                        color: Colors.teal,
                                        onTap: () => context
                                            .read<MatchingBloc>()
                                            .add(SelectLeftTile(wordIndex: i)),
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
                            (i) => MatchingTile(
                              text: state.round.definitions![i],
                              isSelected: state.selectedRightIndex == i,
                              isMatched:
                                  state.matchedTranslationIndices.contains(i),
                              isCorrect:
                                  state.matchedTranslationIndices.contains(i)
                                      ? true
                                      : null,
                              color: Colors.indigo,
                              onTap: () => context
                                  .read<MatchingBloc>()
                                  .add(SelectRightTile(translationIndex: i)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildColumn(
                          title: 'Palabras',
                          items: List.generate(
                            state.round.words.length,
                            (i) => MatchingTile(
                              text: state.round.words[i].word,
                              isSelected: state.selectedLeftIndex == i,
                              isMatched: state.matchedWordIndices.contains(i),
                              isCorrect: state.matchedWordIndices.contains(i)
                                  ? true
                                  : null,
                              color: Colors.teal,
                              onTap: () => context
                                  .read<MatchingBloc>()
                                  .add(SelectLeftTile(wordIndex: i)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildColumn(
                          title: 'Traducciones',
                          items: List.generate(
                            state.round.translations.length,
                            (i) => MatchingTile(
                              text: state.round.translations[i].wordTranslate,
                              isSelected: state.selectedRightIndex == i,
                              isMatched:
                                  state.matchedTranslationIndices.contains(i),
                              isCorrect:
                                  state.matchedTranslationIndices.contains(i)
                                      ? true
                                      : null,
                              color: Colors.indigo,
                              onTap: () => context
                                  .read<MatchingBloc>()
                                  .add(SelectRightTile(translationIndex: i)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (isRoundComplete)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
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
