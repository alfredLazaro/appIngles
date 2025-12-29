import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
abstract class PracticeState extends Equatable {
  const PracticeState();
}

class PracticeInitial extends PracticeState {
  @override
  List<Object> get props => [];
}

class PracticeLoading extends PracticeState {
  @override
  List<Object> get props => [];
}

class PracticeDataLoaded extends PracticeState {
  final int totalCount;
  
  const PracticeDataLoaded(this.totalCount);
  
  @override
  List<Object> get props => [totalCount];
}

class PracticeReady extends PracticeState {
  final PracticeData practiceData;
  
  const PracticeReady(this.practiceData);
  
  @override
  List<Object> get props => [practiceData];
}

class PracticeError extends PracticeState {
  final String message;
  
  const PracticeError(this.message);
  
  @override
  List<Object> get props => [message];
}