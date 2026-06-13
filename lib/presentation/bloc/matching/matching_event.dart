import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/match_round.dart';

abstract class MatchingEvent extends Equatable {
  const MatchingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMatching extends MatchingEvent {
  final List<MatchRound> rounds;

  const InitializeMatching({required this.rounds});

  @override
  List<Object?> get props => [rounds];
}

class SelectLeftTile extends MatchingEvent {
  final int wordIndex;

  const SelectLeftTile({required this.wordIndex});

  @override
  List<Object?> get props => [wordIndex];
}

class SelectRightTile extends MatchingEvent {
  final int translationIndex;

  const SelectRightTile({required this.translationIndex});

  @override
  List<Object?> get props => [translationIndex];
}

class NextMatchingRound extends MatchingEvent {
  const NextMatchingRound();
}

class FinishMatching extends MatchingEvent {
  const FinishMatching();
}
