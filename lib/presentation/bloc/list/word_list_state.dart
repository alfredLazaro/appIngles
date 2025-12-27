import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/word_with_image.dart';

abstract class WordListState {}

class WordListInitial extends WordListState {}

class WordListLoading extends WordListState {}

class WordListLoaded extends WordListState {
  final List<WordWithImage> words;
  WordListLoaded(this.words);
}

class WordListError extends WordListState {
  final String message;

  WordListError(this.message);

  @override
  List<Object?> get props => [message];
}
