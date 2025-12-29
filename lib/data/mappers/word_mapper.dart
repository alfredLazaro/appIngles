import 'package:first_app/data/models/word_model.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:logger/logger.dart';

/// Convierte entre modelo de datos y entidad de dominio
class WordMapper {
  static final _logger = Logger();
  static Word toEntity(WordModel model) {
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

  static WordModel toModel(Word entity) {
    return WordModel(
      id: entity.id,
      word: entity.word,
      definition: entity.definition,
      sentence: entity.sentence,
      learn: entity.learnCount,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  static List<Word> toEntityList(List<WordModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static WordSummary toSummaryEntity(Map<String, dynamic> map) {
    return WordSummary(
      id: map['id'],
      word: map['word'] ?? '',
      sentence: map['sentence'] ?? '',
    );
  }

  static List<WordSummary> toSummaryList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => toSummaryEntity(map)).toList();
  }

  static WordWithImage toWordWithImage(Map<String, dynamic> map) {
    return WordWithImage(
      id: map['id'],
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
      tinyImageUrl: map['tinyImageUrl'], // Puede ser null
    );
  }

  static List<WordWithImage> toWordWithImageList(
      List<Map<String, dynamic>> maps) {
    return maps.map(toWordWithImage).toList();
  }

  static Word fromMapToEntity(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int,
      word: map['word'] as String,
      definition: map['definition'] as String,
      sentence: map['sentence'],
      learnCount: map['learn'] as int? ?? 0,
      createdAt: DateTime.now(), // You might need to parse from map
      updatedAt: DateTime.now(), // You might need to parse from map
    );
  }

  static FlashcardWord toFlashcardWord(Map<String, dynamic> map) {
    return FlashcardWord(
      id: map['id'] as int,
      word: map['word'] as String,
      definition: map['definition'] as String,
      sentence: map['sentence'],
      learnCount: map['learn'],
    );
  }
}
