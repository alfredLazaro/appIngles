// presentation/blocs/translation/translation_event.dart
//part of 'translation_bloc.dart';

import 'package:equatable/equatable.dart';

abstract class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object?> get props => [];
}

class LoadTranslationsByWordIdEvent extends TranslationEvent {
  final int wordId;

  const LoadTranslationsByWordIdEvent(this.wordId);

  @override
  List<Object?> get props => [wordId];
}

class LoadAllTranslationsEvent extends TranslationEvent {
  const LoadAllTranslationsEvent();
}

class SearchTranslationsEvent extends TranslationEvent {
  final String searchTerm;

  const SearchTranslationsEvent(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

class AddTranslationEvent extends TranslationEvent {
  final int wordId;
  final String wordTranslate;
  final List<String> alternatives;

  const AddTranslationEvent({
    required this.wordId,
    required this.wordTranslate,
    this.alternatives = const [],
  });

  @override
  List<Object?> get props => [wordId, wordTranslate, alternatives];
}

class AddBulkTranslationsEvent extends TranslationEvent {
  final int wordId;
  final List<Map<String, dynamic>> translations;

  const AddBulkTranslationsEvent({
    required this.wordId,
    required this.translations,
  });

  @override
  List<Object?> get props => [wordId, translations];
}

class UpdateTranslationEvent extends TranslationEvent {
  final int id;
  final String? wordTranslate;
  final List<String>? alternatives;

  const UpdateTranslationEvent({
    required this.id,
    this.wordTranslate,
    this.alternatives,
  });

  @override
  List<Object?> get props => [id, wordTranslate, alternatives];
}

class DeleteTranslationEvent extends TranslationEvent {
  final int id;

  const DeleteTranslationEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteTranslationsByWordIdEvent extends TranslationEvent {
  final int wordId;

  const DeleteTranslationsByWordIdEvent(this.wordId);

  @override
  List<Object?> get props => [wordId];
}

class GetTranslationCountEvent extends TranslationEvent {
  final int wordId;

  const GetTranslationCountEvent(this.wordId);

  @override
  List<Object?> get props => [wordId];
}

class GetTranslationByIdEvent extends TranslationEvent {
  final int id;

  const GetTranslationByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetTranslationsWithWordDetailsEvent extends TranslationEvent {
  final int wordId;

  const GetTranslationsWithWordDetailsEvent(this.wordId);

  @override
  List<Object?> get props => [wordId];
}
