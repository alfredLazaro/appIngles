// presentation/blocs/translation/translation_state.dart
//part of 'translation_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/presentation/bloc/translation/translation_event.dart';

abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object?> get props => [];
}

class TranslationInitial extends TranslationState {}

class TranslationLoading extends TranslationState {}

class TranslationLoaded extends TranslationState {
  final List<TranslationEntity> translations;
  final int? word_id;
  final int? translationCount;

  const TranslationLoaded({
    required this.translations,
    this.word_id,
    this.translationCount,
  });

  @override
  List<Object?> get props => [translations, word_id, translationCount];
}

class TranslationDetailLoaded extends TranslationState {
  final TranslationEntity translation;
  final Map<String, dynamic>? wordDetails;

  const TranslationDetailLoaded({
    required this.translation,
    this.wordDetails,
  });

  @override
  List<Object?> get props => [translation, wordDetails];
}

class TranslationAdded extends TranslationState {
  final TranslationEntity translation;

  const TranslationAdded(this.translation);

  @override
  List<Object?> get props => [translation];
}

class TranslationsBulkAdded extends TranslationState {
  final List<TranslationEntity> translations;

  const TranslationsBulkAdded(this.translations);

  @override
  List<Object?> get props => [translations];
}

class TranslationUpdated extends TranslationState {
  final TranslationEntity translation;

  const TranslationUpdated(this.translation);

  @override
  List<Object?> get props => [translation];
}

class TranslationDeleted extends TranslationState {
  final int id;

  const TranslationDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class TranslationCountLoaded extends TranslationState {
  final int word_id;
  final int count;

  const TranslationCountLoaded({
    required this.word_id,
    required this.count,
  });

  @override
  List<Object?> get props => [word_id, count];
}

class TranslationError extends TranslationState {
  final String message;
  final TranslationEvent? failedEvent;

  const TranslationError(this.message, {this.failedEvent});

  @override
  List<Object?> get props => [message, failedEvent];
}
