import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/bloc/practice/practice_event.dart';
import 'package:first_app/presentation/bloc/matching/matching_bloc.dart';
import 'package:first_app/presentation/bloc/matching/matching_event.dart';
import 'package:first_app/presentation/bloc/matching/matching_state.dart';
import 'package:first_app/presentation/widgets/practice_results_widget.dart';
import 'package:first_app/presentation/widgets/matching_progress_bar.dart';
import 'package:first_app/presentation/widgets/matching_translation_layout.dart';
import 'package:first_app/presentation/widgets/matching_definition_layout.dart';
import 'package:first_app/presentation/widgets/matching_animation_controller.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';

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
  late final MatchingBloc _matchingBloc;
  late final MatchingAnimationController _animationController;
  int? _pendingLeftIndex;
  int? _pendingRightIndex;

  int get _totalPairs => widget.data.rounds.fold<int>(
        0,
        (sum, r) => sum + r.words.length,
      );

  @override
  void initState() {
    super.initState();
    _matchingBloc = MatchingBloc()
      ..add(InitializeMatching(rounds: widget.data.rounds));
    _animationController = MatchingAnimationController();
  }

  @override
  void dispose() {
    _matchingBloc.close();
    _animationController.dispose();
    super.dispose();
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

  void _onLeftTap(int index) {
    _pendingLeftIndex = index;
    _matchingBloc.add(SelectLeftTile(wordIndex: index));
  }

  void _onRightTap(int index) {
    _pendingRightIndex = index;
    _matchingBloc.add(SelectRightTile(translationIndex: index));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _matchingBloc,
      child: BlocConsumer<MatchingBloc, MatchingState>(
        listener: (context, state) {
          if (state is MatchingCompleted) {
            _submitResult(state);
          } else if (state is MatchingRoundReady) {
            _animationController.onStateChange(
              state,
              _pendingLeftIndex,
              _pendingRightIndex,
            );
          }
        },
        builder: (context, state) {
          if (state is MatchingCompleted) {
            return PracticeResultsWidget(
              practiceType: widget.isDefinitionMode
                  ? PracticeType.matchingDefinition
                  : PracticeType.matching,
              totalItems: _totalPairs,
              correctItems: state.totalCorrect,
              words: widget.data.words,
              learnCountUpdates: state.learnCountUpdates,
              onFinish: () => Navigator.pop(context),
              accentColor: const Color(0xFF413FE6),
            );
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

  Widget _buildRound(BuildContext context, MatchingRoundReady state) {
    final isRoundComplete =
        state.matchedWordIndices.length == state.round.words.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
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
                  color: AppColors.progressGreen,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          MatchingProgressBar(
            matched: state.matchedWordIndices.length,
            total: state.round.words.length,
            roundIndex: state.roundIndex,
            totalRounds: state.totalRounds,
          ),
          if (state.lastAttemptCorrect != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: state.lastAttemptCorrect!
                  ? AppColors.successLight.withValues(alpha: 0.3)
                  : AppColors.errorLight,
              child: Center(
                child: Text(
                  state.lastAttemptCorrect!
                      ? '¡Correcto!'
                      : 'Incorrecto, intenta de nuevo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: state.lastAttemptCorrect!
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListenableBuilder(
              listenable: _animationController,
              builder: (context, _) {
                return widget.isDefinitionMode
                    ? MatchingDefinitionLayout(
                        state: state,
                        controller: _animationController,
                        onLeftTap: _onLeftTap,
                        onRightTap: _onRightTap,
                      )
                    : MatchingTranslationLayout(
                        state: state,
                        controller: _animationController,
                        onLeftTap: _onLeftTap,
                        onRightTap: _onRightTap,
                      );
              },
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
                    backgroundColor: FlashcardConstants.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _matchingBloc.add(const NextMatchingRound());
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
}
