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
    on<LoadTranslationsByword_idEvent>(_onLoadTranslationsByword_id);
    on<LoadAllTranslationsEvent>(_onLoadAllTranslations);
    on<SearchTranslationsEvent>(_onSearchTranslations);
    on<AddTranslationEvent>(_onAddTranslation);
    on<AddBulkTranslationsEvent>(_onAddBulkTranslations);
    on<UpdateTranslationEvent>(_onUpdateTranslation);
    on<DeleteTranslationEvent>(_onDeleteTranslation);
    on<DeleteTranslationsByword_idEvent>(_onDeleteTranslationsByword_id);
    on<GetTranslationCountEvent>(_onGetTranslationCount);
    on<GetTranslationByIdEvent>(_onGetTranslationById);
    on<GetTranslationsWithWordDetailsEvent>(_onGetTranslationsWithWordDetails);
  }

  Future<void> _onLoadTranslationsByword_id(
    LoadTranslationsByword_idEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final entities =
          await translationRepository.getTranslationsByword_id(event.word_id);

      emit(TranslationLoaded(
        translations: entities,
        word_id: event.word_id,
      ));
    } catch (e) {
      emit(TranslationError(
        'Error loading translations for word ID ${event.word_id}: $e',
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
        event.word_id,
        event.wordTranslate,
        event.alternatives,
      );

      final newTranslation = TranslationEntity(
        id: id,
        word_id: event.word_id,
        wordTranslate: event.wordTranslate,
        alternatives: event.alternatives,
        createdAt: DateTime.now(),
      );

      emit(TranslationAdded(newTranslation));

      add(LoadTranslationsByword_idEvent(event.word_id));
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
          word_id: event.word_id,
          wordTranslate: t['wordTranslate'] as String,
          alternatives: alternatives,
        );
      }).toList();

      final ids = await translationRepository.insertTranslations(
        event.word_id,
        entities,
      );

      final newTranslations =
          List<TranslationEntity>.generate(ids.length, (index) {
        final original = entities[index];
        return TranslationEntity(
          id: ids[index],
          word_id: original.word_id,
          wordTranslate: original.wordTranslate,
          alternatives: original.alternatives,
          createdAt: DateTime.now(),
        );
      });

      emit(TranslationsBulkAdded(newTranslations));

      add(LoadTranslationsByword_idEvent(event.word_id));
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

          add(LoadTranslationsByword_idEvent(updatedEntity.word_id));
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

        add(LoadTranslationsByword_idEvent(translation.word_id));
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

  Future<void> _onDeleteTranslationsByword_id(
    DeleteTranslationsByword_idEvent event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    try {
      final affectedRows =
          await translationRepository.deleteTranslationsByword_id(event.word_id);

      if (affectedRows > 0) {
        emit(TranslationLoaded(translations: [], word_id: event.word_id));
      } else {
        emit(TranslationError(
          'No translations found for word ID ${event.word_id}',
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
          await translationRepository.getTranslationCount(event.word_id);

      emit(TranslationCountLoaded(
        word_id: event.word_id,
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
          .getTranslationsWithWordDetails(event.word_id);

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
          word_id: event.word_id,
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
