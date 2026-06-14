import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/entities/word.dart';

abstract class WordDetailEvent extends Equatable {
  const WordDetailEvent();
}

class LoadWordDetailEvent extends WordDetailEvent {
  final int wordId;

  const LoadWordDetailEvent(this.wordId);

  @override
  List<Object?> get props => [wordId];
}

class SaveWordDetailEvent extends WordDetailEvent {
  final Word updatedWord;
  final List<int> translationIdsToDelete;
  final List<TranslationEntity> newTranslations;

  const SaveWordDetailEvent({
    required this.updatedWord,
    required this.translationIdsToDelete,
    required this.newTranslations,
  });

  @override
  List<Object?> get props => [updatedWord, translationIdsToDelete, newTranslations];
}

class DeleteWordDetailEvent extends WordDetailEvent {
  final int wordId;

  const DeleteWordDetailEvent(this.wordId);

  @override
  List<Object?> get props => [wordId];
}

class AddImagesToWordEvent extends WordDetailEvent {
  final List<Map<String, dynamic>> images;

  const AddImagesToWordEvent(this.images);

  @override
  List<Object?> get props => [images];
}
