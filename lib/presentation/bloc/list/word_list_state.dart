import 'package:equatable/equatable.dart';
abstract class WordListState {}
class WordListInitial extends WordListState {}
class WordListLoading extends WordListState {}
class WordListLoaded extends WordListState {
  final List<WordWithImage> words;
  WordListLoaded(this.words);
}