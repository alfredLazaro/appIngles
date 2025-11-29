import 'package:first_app/data/models/pf_ing_model.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:logger/logger.dart';

/// Convierte entre modelo de datos y entidad de dominio
class WordMapper {
  static final _logger = Logger();
  static Word toEntity(PfIng model) {
    // ✅ Debug: Ver qué datos llegan
    _logger.d('Parseando palabra: ${model.word}');
    _logger.d('createdAt: "${model.createdAt}"');
    _logger.d('updatedAt: "${model.updatedAt}"');
    return Word(
      id: model.id,
      word: model.word,
      definition: model.definition,
      sentence: model.sentence,
      learnCount: model.learn,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: DateTime.parse(model.updatedAt),
    );
  }

  static PfIng toModel(Word entity) {
    return PfIng(
      id: entity.id,
      word: entity.word,
      definition: entity.definition,
      sentence: entity.sentence,
      learn: entity.learnCount,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  static List<Word> toEntityList(List<PfIng> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static WordSummary toSummaryEntity(Map<String, dynamic> map) {
    return WordSummary(
      id: map['id'],
      word: map['word'] ?? '',
      sentence: map['sentence'] ?? '',
      tinyImageUrl: map['tinyImageUrl'], // ✅ Si haces JOIN con images
    );
  }

  static List<WordSummary> toSummaryList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => toSummaryEntity(map)).toList();
  }
}
