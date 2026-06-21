import 'package:equatable/equatable.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';

abstract class PracticeEvent extends Equatable {
  const PracticeEvent();
}

class LoadPracticeDataEvent extends PracticeEvent {
  final PracticeType type;
  const LoadPracticeDataEvent(this.type);

  @override
  List<Object> get props => [type];
}

class StartPracticeEvent extends PracticeEvent {
  final int count;
  final PracticeType type;
  final int maxAudioPlays;

  const StartPracticeEvent(this.count, this.type, {this.maxAudioPlays = 0});

  @override
  List<Object> get props => [count, type, maxAudioPlays];
}

class FinishPracticeEvent extends PracticeEvent {
  final PracticeResult result;

  const FinishPracticeEvent(this.result);

  @override
  List<Object> get props => [result];
}
