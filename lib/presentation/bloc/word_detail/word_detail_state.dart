import 'package:equatable/equatable.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_image.dart';

abstract class WordDetailState extends Equatable {
  const WordDetailState();
}

class WordDetailInitial extends WordDetailState {
  const WordDetailInitial();

  @override
  List<Object?> get props => [];
}

class WordDetailLoading extends WordDetailState {
  const WordDetailLoading();

  @override
  List<Object?> get props => [];
}

class WordDetailLoaded extends WordDetailState {
  final Word word;
  final List<TranslationEntity> translations;
  final List<WordImage> images;
  final bool isSaving;
  final String? errorMessage;

  const WordDetailLoaded({
    required this.word,
    required this.translations,
    required this.images,
    this.isSaving = false,
    this.errorMessage,
  });

  WordDetailLoaded copyWith({
    Word? word,
    List<TranslationEntity>? translations,
    List<WordImage>? images,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WordDetailLoaded(
      word: word ?? this.word,
      translations: translations ?? this.translations,
      images: images ?? this.images,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [word, translations, images, isSaving, errorMessage];
}

class WordDetailError extends WordDetailState {
  final String message;

  const WordDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class WordDetailDeleted extends WordDetailState {
  const WordDetailDeleted();

  @override
  List<Object?> get props => [];
}
