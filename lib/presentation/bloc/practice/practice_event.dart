import 'package:equatable/equatable.dart';
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
  
  const StartPracticeEvent(this.count, this.type);
  
  @override
  List<Object> get props => [count, type];
}