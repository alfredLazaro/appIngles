// data/models/translation_model.dart
class TranslationModel {
  final int? id;
  final String wordTranslate;
  final int wordId;
  final String? alternatives;

  TranslationModel({
    this.id,
    required this.wordTranslate,
    required this.wordId,
    this.alternatives,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'wordTranslate': wordTranslate,
      'wordId': wordId,
      'alternatives': alternatives,
    };
  }

  factory TranslationModel.fromMap(Map<String, dynamic> map) {
    return TranslationModel(
      id: map['id'] as int?,
      wordTranslate: map['wordTranslate'] as String,
      wordId: map['wordId'] as int,
      alternatives: map['alternatives'] as String?,
    );
  }

  // Convert to entity
  Translation toEntity() {
    return Translation(
      id: id,
      wordTranslate: wordTranslate,
      wordId: wordId,
      alternatives: alternatives,
    );
  }

  // Create from entity
  factory TranslationModel.fromEntity(Translation entity) {
    return TranslationModel(
      id: entity.id,
      wordTranslate: entity.wordTranslate,
      wordId: entity.wordId,
      alternatives: entity.alternatives,
    );
  }
}