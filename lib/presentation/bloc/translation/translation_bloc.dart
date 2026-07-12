// presentation/blocs/translation/translation_bloc.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
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
      final entities =
          await translationRepository.getTranslationsByWordId(event.wordId);

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
      final entities = await translationRepository.getAllTranslations();

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
      final entities =
          await translationRepository.searchTranslations(event.searchTerm);

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
      final id = await translationRepository.insertTranslation(
        event.wordId,
        event.wordTranslate,
        event.alternatives,
      );

      final newTranslation = TranslationEntity(
        id: id,
        wordId: event.wordId,
        wordTranslate: event.wordTranslate,
        alternatives: event.alternatives,
        createdAt: DateTime.now(),
      );

      emit(TranslationAdded(newTranslation));

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
      final entities = event.translations.map((t) {
        final alternatives = (t['alternatives'] as String? ?? '')
            .split('|')
            .where((item) => item.isNotEmpty)
            .toList();
        return TranslationEntity(
          wordId: event.wordId,
          wordTranslate: t['wordTranslate'] as String,
          alternatives: alternatives,
        );
      }).toList();

      final ids = await translationRepository.insertTranslations(
        event.wordId,
        entities,
      );

      final newTranslations =
          List<TranslationEntity>.generate(ids.length, (index) {
        final original = entities[index];
        return TranslationEntity(
          id: ids[index],
          wordId: original.wordId,
          wordTranslate: original.wordTranslate,
          alternatives: original.alternatives,
          createdAt: DateTime.now(),
        );
      });

      emit(TranslationsBulkAdded(newTranslations));

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
      if (event.wordTranslate == null && event.alternatives == null) {
        emit(TranslationError(
          'No fields to update',
          failedEvent: event,
        ));
        return;
      }

      final affectedRows = await translationRepository.updateTranslation(
        event.id,
        event.wordTranslate,
        event.alternatives,
      );

      if (affectedRows > 0) {
        final updatedEntity =
            await translationRepository.getTranslationById(event.id);

        if (updatedEntity != null) {
          emit(TranslationUpdated(updatedEntity));

          add(LoadTranslationsByWordIdEvent(updatedEntity.wordId));
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
        emit(TranslationDeleted(event.id));

        add(LoadTranslationsByWordIdEvent(translation.wordId));
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
      final entity =
          await translationRepository.getTranslationById(event.id);

      if (entity != null) {
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

      final wordDetails = translations.isNotEmpty
          ? {
              'word': translations.first['word'],
              'definition': translations.first['definition'],
              'sentence': translations.first['sentence'],
            }
          : null;

      emit(TranslationDetailLoaded(
        translation: TranslationEntity(
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

  @visibleForTesting
  TranslationState get currentState => state;
}
