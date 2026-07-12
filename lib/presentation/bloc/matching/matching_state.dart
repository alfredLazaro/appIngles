import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/match_round.dart';

abstract class MatchingState extends Equatable {
  const MatchingState();

  @override
  List<Object?> get props => [];
}

class MatchingInitial extends MatchingState {
  const MatchingInitial();
}

class MatchingRoundReady extends MatchingState {
  final MatchRound round;
  final int roundIndex;
  final int totalRounds;
  final int? selectedLeftIndex;
  final int? selectedRightIndex;
  final Set<int> matchedWordIndices;
  final Set<int> matchedTranslationIndices;
  final bool? lastAttemptCorrect;
  final int totalCorrect;

  const MatchingRoundReady({
    required this.round,
    required this.roundIndex,
    required this.totalRounds,
    this.selectedLeftIndex,
    this.selectedRightIndex,
    this.matchedWordIndices = const {},
    this.matchedTranslationIndices = const {},
    this.lastAttemptCorrect,
    this.totalCorrect = 0,
  });

  MatchingRoundReady copyWith({
    MatchRound? round,
    int? roundIndex,
    int? totalRounds,
    int? selectedLeftIndex,
    int? selectedRightIndex,
    Set<int>? matchedWordIndices,
    Set<int>? matchedTranslationIndices,
    bool? lastAttemptCorrect,
    int? totalCorrect,
    bool clearSelection = false,
  }) {
    return MatchingRoundReady(
      round: round ?? this.round,
      roundIndex: roundIndex ?? this.roundIndex,
      totalRounds: totalRounds ?? this.totalRounds,
      selectedLeftIndex: clearSelection
          ? null
          : (selectedLeftIndex ?? this.selectedLeftIndex),
      selectedRightIndex: clearSelection
          ? null
          : (selectedRightIndex ?? this.selectedRightIndex),
      matchedWordIndices: matchedWordIndices ?? this.matchedWordIndices,
      matchedTranslationIndices:
          matchedTranslationIndices ?? this.matchedTranslationIndices,
      lastAttemptCorrect: lastAttemptCorrect ?? this.lastAttemptCorrect,
      totalCorrect: totalCorrect ?? this.totalCorrect,
    );
  }

  @override
  List<Object?> get props => [
        round,
        roundIndex,
        totalRounds,
        selectedLeftIndex,
        selectedRightIndex,
        matchedWordIndices,
        matchedTranslationIndices,
        lastAttemptCorrect,
        totalCorrect,
      ];
}

class MatchingCompleted extends MatchingState {
  final int totalRounds;
  final int totalCorrect;
  final Map<int, int> learnCountUpdates;

  const MatchingCompleted({
    required this.totalRounds,
    required this.totalCorrect,
    this.learnCountUpdates = const {},
  });

  @override
  List<Object?> get props => [totalRounds, totalCorrect, learnCountUpdates];
}
