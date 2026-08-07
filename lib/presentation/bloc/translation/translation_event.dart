// presentation/blocs/translation/translation_event.dart
//part of 'translation_bloc.dart';

import 'package:equatable/equatable.dart';

abstract class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object?> get props => [];
}

class LoadTranslationsByword_idEvent extends TranslationEvent {
  final int word_id;

  const LoadTranslationsByword_idEvent(this.word_id);

  @override
  List<Object?> get props => [word_id];
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
  final int word_id;
  final String wordTranslate;
  final List<String> alternatives;

  const AddTranslationEvent({
    required this.word_id,
    required this.wordTranslate,
    this.alternatives = const [],
  });

  @override
  List<Object?> get props => [word_id, wordTranslate, alternatives];
}

class AddBulkTranslationsEvent extends TranslationEvent {
  final int word_id;
  final List<Map<String, dynamic>> translations;

  const AddBulkTranslationsEvent({
    required this.word_id,
    required this.translations,
  });

  @override
  List<Object?> get props => [word_id, translations];
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

class DeleteTranslationsByword_idEvent extends TranslationEvent {
  final int word_id;

  const DeleteTranslationsByword_idEvent(this.word_id);

  @override
  List<Object?> get props => [word_id];
}

class GetTranslationCountEvent extends TranslationEvent {
  final int word_id;

  const GetTranslationCountEvent(this.word_id);

  @override
  List<Object?> get props => [word_id];
}

class GetTranslationByIdEvent extends TranslationEvent {
  final int id;

  const GetTranslationByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetTranslationsWithWordDetailsEvent extends TranslationEvent {
  final int word_id;

  const GetTranslationsWithWordDetailsEvent(this.word_id);

  @override
  List<Object?> get props => [word_id];
}
