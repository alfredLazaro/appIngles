// data/mappers/translation_mapper.dart
import 'package:first_app/data/datasources/local/db_constants.dart';
import 'package:first_app/domain/entities/translation.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/entities/translation_with_word.dart';

class TranslationMapper {
  // ============ TranslationEntity (v2) ============

  TranslationEntity mapToTranslationEntity(Map<String, dynamic> map) {
    return TranslationEntity(
      id: map[TranslationFields.id] as int?,
      wordId: (map[TranslationFields.wordId] as num?)?.toInt() ?? 0,
      wordTranslate:
          map[TranslationFields.wordTranslate] as String? ?? '',
      alternatives: (map[TranslationFields.alternatives] as String? ?? '')
          .split('|')
          .where((item) => item.isNotEmpty)
          .toList(),
      createdAt: map[TranslationFields.createdAt] != null
          ? DateTime.parse(map[TranslationFields.createdAt] as String)
          : null,
    );
  }

  List<TranslationEntity> mapToTranslationEntityList(
      List<Map<String, dynamic>> maps) {
    return maps.map((map) => mapToTranslationEntity(map)).toList();
  }

  Map<String, dynamic> translationEntityToMap(TranslationEntity entity) {
    return {
      if (entity.id != null) TranslationFields.id: entity.id,
      TranslationFields.wordId: entity.wordId,
      TranslationFields.wordTranslate: entity.wordTranslate,
      TranslationFields.alternatives: entity.alternatives.join('|'),
    };
  }

  // ============ Translation (v1, deprecated) ============

  Translation mapToEntity(Map<String, dynamic> map) {
    return Translation.fromMap(map);
  }

  List<Translation> mapToEntityList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => mapToEntity(map)).toList();
  }

  Map<String, dynamic> mapToDatabase(Translation entity) {
    return {
      TranslationFields.wordId: entity.wordId,
      TranslationFields.wordTranslate: entity.wordTranslate,
      TranslationFields.alternatives: entity.alternatives,
    };
  }

  List<Map<String, dynamic>> mapToDatabaseList(List<Translation> entities) {
    return entities.map((entity) => mapToDatabase(entity)).toList();
  }

  // ============ TranslationWithWord ============

  TranslationWithWord mapToTranslationWithWord(Map<String, dynamic> map) {
    return TranslationWithWord.fromMap(map);
  }

  List<TranslationWithWord> mapToTranslationWithWordList(
    List<Map<String, dynamic>> maps,
  ) {
    return maps.map((map) => mapToTranslationWithWord(map)).toList();
  }

  // Convert raw translation data to entity (for API responses)
  Translation mapRawToEntity({
    int? id,
    required String wordTranslate,
    required int wordId,
    String? alternatives,
  }) {
    return Translation(
      id: id,
      wordTranslate: wordTranslate,
      wordId: wordId,
      alternatives: alternatives,
    );
  }
}
