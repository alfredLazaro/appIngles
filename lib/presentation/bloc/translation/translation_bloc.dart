// presentation/blocs/translation/translation_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:first_app/data/datasources/local/db_constants.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/presentation/bloc/translation/translation_event.dart';
import 'package:first_app/presentation/bloc/translation/translation_state.dart';
import 'package:flutter/material.dart';

class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final TranslationRepository translationRepository;

  TranslationBloc({required this.translationRepository})
      : super(TranslationInitial()) {
    on<LoadTranslationsByWordIdEvent>(_onLoadTranslationsByWordId);
    on<LoadAllTranslationsEvent>(_onLoadAllTranslations);
    on<SearchTranslationsEvent>(_onSearchTranslations);
    on<AddTranslationEvent>(_onAddTranslation);
    on<AddBulkTranslationsEvent>(_onAddBulkTranslations);
    on<UpdateTranslationEvent>(_onUpdateTranslation);
    on<DeleteTranslationEvent>(_onDeleteTranslation);
    on<DeleteTranslationsByWordIdEvent>(_onDeleteTranslationsByWordId);
    on<GetTranslationCountEvent>(_onGetTranslationCount);
    on<GetTranslationByIdEvent>(_onGetTranslationById);
    on<GetTranslationsWithWordDetailsEvent>(_onGetTranslationsWithWordDetails);
  }

  Future<void> _onLoadTranslationsByWordId(
    LoadTranslationsByWordIdEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final translations =
          await translationRepository.getTranslationsByWordId(event.wordId);

      final entities =
          translations.map((map) => TranslationEntity.fromMap(map)).toList();

      emit(TranslationLoaded(
        translations: entities,
        wordId: event.wordId,
      ));
    } catch (e) {
      emit(TranslationError(
        'Error loading translations for word ID ${event.wordId}: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onLoadAllTranslations(
    LoadAllTranslationsEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final translations = await translationRepository.getAllTranslations();

      final entities =
          translations.map((map) => TranslationEntity.fromMap(map)).toList();

      emit(TranslationLoaded(translations: entities));
    } catch (e) {
      emit(TranslationError(
        'Error loading all translations: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onSearchTranslations(
    SearchTranslationsEvent event,
    Emitter<TranslationState> emit,
  ) async {
    if (event.searchTerm.isEmpty) {
      add(const LoadAllTranslationsEvent());
      return;
    }

    emit(TranslationLoading());

    try {
      final translations =
          await translationRepository.searchTranslations(event.searchTerm);

      final entities =
          translations.map((map) => TranslationEntity.fromMap(map)).toList();

      emit(TranslationLoaded(translations: entities));
    } catch (e) {
      emit(TranslationError(
        'Error searching translations: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onAddTranslation(
    AddTranslationEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final translationMap = {
        TranslationFields.wordId: event.wordId,
        TranslationFields.wordTranslate: event.wordTranslate,
        TranslationFields.alternatives: event.alternatives.join('|'),
      };

      final id = await translationRepository.insertTranslation(translationMap);

      final newTranslation = TranslationEntity(
        id: id,
        wordId: event.wordId,
        wordTranslate: event.wordTranslate,
        alternatives: event.alternatives,
        createdAt: DateTime.now(),
      );

      emit(TranslationAdded(newTranslation));

      // Reload translations for this word
      add(LoadTranslationsByWordIdEvent(event.wordId));
    } catch (e) {
      emit(TranslationError(
        'Error adding translation: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onAddBulkTranslations(
    AddBulkTranslationsEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      // Prepare translations with wordId
      final preparedTranslations = event.translations.map((translation) {
        return {
          ...translation,
          TranslationFields.wordId: event.wordId,
        };
      }).toList();

      final ids = await translationRepository.insertTranslations(
        event.wordId,
        preparedTranslations,
      );

      // Create translation entities from the inserted data
      final newTranslations =
          List<TranslationEntity>.generate(ids.length, (index) {
        final originalTranslation = preparedTranslations[index];
        return TranslationEntity(
          id: ids[index],
          wordId: event.wordId,
          wordTranslate:
              originalTranslation[TranslationFields.wordTranslate] as String,
          alternatives:
              (originalTranslation[TranslationFields.alternatives] as String? ??
                      '')
                  .split('|')
                  .where((item) => item.isNotEmpty)
                  .toList(),
          createdAt: DateTime.now(),
        );
      });

      emit(TranslationsBulkAdded(newTranslations));

      // Reload translations for this word
      add(LoadTranslationsByWordIdEvent(event.wordId));
    } catch (e) {
      emit(TranslationError(
        'Error adding bulk translations: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onUpdateTranslation(
    UpdateTranslationEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final translationMap = <String, dynamic>{};

      if (event.wordTranslate != null) {
        translationMap[TranslationFields.wordTranslate] = event.wordTranslate;
      }

      if (event.alternatives != null) {
        translationMap[TranslationFields.alternatives] =
            event.alternatives!.join('|');
      }

      if (translationMap.isEmpty) {
        emit(TranslationError(
          'No fields to update',
          failedEvent: event,
        ));
        return;
      }

      final affectedRows = await translationRepository.updateTranslation(
        event.id,
        translationMap,
      );

      if (affectedRows > 0) {
        // Get the updated translation
        final updatedTranslation =
            await translationRepository.getTranslationById(event.id);

        if (updatedTranslation != null) {
          final entity = TranslationEntity.fromMap(updatedTranslation);
          emit(TranslationUpdated(entity));

          // Reload translations for this word
          add(LoadTranslationsByWordIdEvent(entity.wordId));
        }
      } else {
        emit(TranslationError(
          'Translation not found or not updated',
          failedEvent: event,
        ));
      }
    } catch (e) {
      emit(TranslationError(
        'Error updating translation: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onDeleteTranslation(
    DeleteTranslationEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      // Get translation to know wordId before deleting
      final translation =
          await translationRepository.getTranslationById(event.id);

      if (translation == null) {
        emit(TranslationError(
          'Translation not found',
          failedEvent: event,
        ));
        return;
      }

      final affectedRows =
          await translationRepository.deleteTranslation(event.id);

      if (affectedRows > 0) {
        final wordId = translation[TranslationFields.wordId] as int;
        emit(TranslationDeleted(event.id));

        // Reload translations for this word
        add(LoadTranslationsByWordIdEvent(wordId));
      } else {
        emit(TranslationError(
          'Failed to delete translation',
          failedEvent: event,
        ));
      }
    } catch (e) {
      emit(TranslationError(
        'Error deleting translation: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onDeleteTranslationsByWordId(
    DeleteTranslationsByWordIdEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final affectedRows =
          await translationRepository.deleteTranslationsByWordId(event.wordId);

      if (affectedRows > 0) {
        emit(TranslationLoaded(translations: [], wordId: event.wordId));
      } else {
        emit(TranslationError(
          'No translations found for word ID ${event.wordId}',
          failedEvent: event,
        ));
      }
    } catch (e) {
      emit(TranslationError(
        'Error deleting translations: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onGetTranslationCount(
    GetTranslationCountEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final count =
          await translationRepository.getTranslationCount(event.wordId);

      emit(TranslationCountLoaded(
        wordId: event.wordId,
        count: count,
      ));
    } catch (e) {
      emit(TranslationError(
        'Error getting translation count: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onGetTranslationById(
    GetTranslationByIdEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final translation =
          await translationRepository.getTranslationById(event.id);

      if (translation != null) {
        final entity = TranslationEntity.fromMap(translation);
        emit(TranslationDetailLoaded(translation: entity));
      } else {
        emit(TranslationError(
          'Translation with ID ${event.id} not found',
          failedEvent: event,
        ));
      }
    } catch (e) {
      emit(TranslationError(
        'Error getting translation by ID: $e',
        failedEvent: event,
      ));
    }
  }

  Future<void> _onGetTranslationsWithWordDetails(
    GetTranslationsWithWordDetailsEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final translations = await translationRepository
          .getTranslationsWithWordDetails(event.wordId);

      final entities =
          translations.map((map) => TranslationEntity.fromMap(map)).toList();

      // Extract word details from first translation (assuming they all have the same word)
      final wordDetails = translations.isNotEmpty
          ? {
              'word': translations.first['word'],
              'definition': translations.first['definition'],
              'sentence': translations.first['sentence'],
            }
          : null;

      emit(TranslationDetailLoaded(
        translation: entities.firstOrNull ??
            TranslationEntity(
              id: -1,
              wordId: event.wordId,
              wordTranslate: '',
            ),
        wordDetails: wordDetails,
      ));
    } catch (e) {
      emit(TranslationError(
        'Error getting translations with word details: $e',
        failedEvent: event,
      ));
    }
  }

  // Helper method to get current state (for testing)
  @visibleForTesting
  TranslationState get currentState => state;
}
