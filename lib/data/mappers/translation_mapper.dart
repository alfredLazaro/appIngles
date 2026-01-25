// data/mappers/translation_mapper.dart
import 'package:first_app/domain/entities/translation.dart';
import 'package:first_app/domain/entities/translation_with_word.dart';
import 'package:first_app/data/models/translation_model.dart';

class TranslationMapper {
  // Map from database result to Translation entity
  Translation mapToEntity(Map<String, dynamic> map) {
    return Translation.fromMap(map);
  }

  // Map list of database results to Translation entities
  List<Translation> mapToEntityList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => mapToEntity(map)).toList();
  }

  // Map from Translation entity to database format
  Map<String, dynamic> mapToDatabase(Translation entity) {
    return TranslationModel.fromEntity(entity).toMap();
  }

  // Map list of entities to database format
  List<Map<String, dynamic>> mapToDatabaseList(List<Translation> entities) {
    return entities.map((entity) => mapToDatabase(entity)).toList();
  }

  // Map from database result with word details to TranslationWithWord entity
  TranslationWithWord mapToTranslationWithWord(Map<String, dynamic> map) {
    return TranslationWithWord.fromMap(map);
  }

  // Map list of database results to TranslationWithWord entities
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