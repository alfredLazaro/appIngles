import 'package:bloc/bloc.dart';
import 'package:first_app/domain/entities/match_round.dart';
import 'package:first_app/presentation/bloc/matching/matching_event.dart';
import 'package:first_app/presentation/bloc/matching/matching_state.dart';

class MatchingBloc extends Bloc<MatchingEvent, MatchingState> {
  late List<MatchRound> _rounds;

  MatchingBloc() : super(const MatchingInitial()) {
    on<InitializeMatching>(_onInitialize);
    on<SelectLeftTile>(_onSelectLeft);
    on<SelectRightTile>(_onSelectRight);
    on<NextMatchingRound>(_onNextRound);
    on<FinishMatching>(_onFinish);
  }

  void _onInitialize(
    InitializeMatching event,
    Emitter<MatchingState> emit,
  ) {
    _rounds = event.rounds;
    if (_rounds.isEmpty) {
      emit(const MatchingCompleted(totalRounds: 0, totalCorrect: 0));
      return;
    }
    emit(MatchingRoundReady(
      round: _rounds.first,
      roundIndex: 0,
      totalRounds: _rounds.length,
    ));
  }

  void _onSelectLeft(
    SelectLeftTile event,
    Emitter<MatchingState> emit,
  ) {
    final state = this.state;
    if (state is! MatchingRoundReady) return;

    final idx = event.wordIndex;
    if (state.matchedWordIndices.contains(idx)) return;

    if (state.selectedRightIndex == null) {
      emit(state.copyWith(
        selectedLeftIndex: idx,
        lastAttemptCorrect: null,
      ));
    } else {
      _evaluateMatch(state, leftIndex: idx, emit: emit);
    }
  }

  void _onSelectRight(
    SelectRightTile event,
    Emitter<MatchingState> emit,
  ) {
    final state = this.state;
    if (state is! MatchingRoundReady) return;

    final idx = event.translationIndex;
    if (state.matchedTranslationIndices.contains(idx)) return;

    if (state.selectedLeftIndex == null) {
      emit(state.copyWith(
        selectedRightIndex: idx,
        lastAttemptCorrect: null,
      ));
    } else {
      _evaluateMatch(state, rightIndex: idx, emit: emit);
    }
  }

  void _evaluateMatch(
    MatchingRoundReady state, {
    int? leftIndex,
    int? rightIndex,
    required Emitter<MatchingState> emit,
  }) {
    final wIdx = leftIndex ?? state.selectedLeftIndex;
    final tIdx = rightIndex ?? state.selectedRightIndex;

    if (wIdx == null || tIdx == null) return;

    final isCorrect = state.round.correctMapping[wIdx] == tIdx;

    if (isCorrect) {
      final newMatchedWord = Set<int>.from(state.matchedWordIndices)
        ..add(wIdx);
      final newMatchedTranslations =
          Set<int>.from(state.matchedTranslationIndices)
            ..add(tIdx);

      emit(state.copyWith(
        selectedLeftIndex: leftIndex ?? state.selectedLeftIndex,
        selectedRightIndex: rightIndex ?? state.selectedRightIndex,
        lastAttemptCorrect: true,
        matchedWordIndices: newMatchedWord,
        matchedTranslationIndices: newMatchedTranslations,
        totalCorrect: state.totalCorrect + 1,
        clearSelection: true,
      ));
    } else {
      emit(state.copyWith(
        selectedLeftIndex: leftIndex ?? state.selectedLeftIndex,
        selectedRightIndex: rightIndex ?? state.selectedRightIndex,
        lastAttemptCorrect: false,
        clearSelection: true,
      ));
    }
  }

  void _onNextRound(
    NextMatchingRound event,
    Emitter<MatchingState> emit,
  ) {
    final state = this.state;
    if (state is! MatchingRoundReady) return;

    final nextIndex = state.roundIndex + 1;
    if (nextIndex >= _rounds.length) {
      emit(MatchingCompleted(
        totalRounds: _rounds.length,
        totalCorrect: state.totalCorrect,
      ));
      return;
    }

    emit(MatchingRoundReady(
      round: _rounds[nextIndex],
      roundIndex: nextIndex,
      totalRounds: _rounds.length,
      totalCorrect: state.totalCorrect,
    ));
  }

  void _onFinish(
    FinishMatching event,
    Emitter<MatchingState> emit,
  ) {
    final state = this.state;
    if (state is! MatchingRoundReady) return;

    emit(MatchingCompleted(
      totalRounds: _rounds.length,
      totalCorrect: state.totalCorrect,
    ));
  }
}
