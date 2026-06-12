// data/models/translation_model.dart
import 'package:first_app/domain/entities/translation_entity.dart';

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

  // Convert to TranslationEntity (v2)
  TranslationEntity toEntity() {
    return TranslationEntity(
      id: id,
      wordTranslate: wordTranslate,
      wordId: wordId,
      alternatives: (alternatives ?? '')
          .split('|')
          .where((item) => item.isNotEmpty)
          .toList(),
    );
  }

  // Create from TranslationEntity (v2)
  factory TranslationModel.fromEntity(TranslationEntity entity) {
    return TranslationModel(
      id: entity.id,
      wordTranslate: entity.wordTranslate,
      wordId: entity.wordId,
      alternatives: entity.alternatives.join('|'),
    );
  }
}
