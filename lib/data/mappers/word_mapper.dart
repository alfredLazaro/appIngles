import 'package:first_app/data/models/word_model.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_def.dart';
import 'package:first_app/domain/entities/word_insertion.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/domain/entities/word_with_image.dart';

/// Convierte entre modelo de datos y entidad de dominio
class WordMapper {
  static Word toEntity(WordModel model) {
    return Word(
      id: model.id,
      word: model.word,
      partOfSpeech: model.partOfSpeech,
      phonetic: model.phonetic,
      definition: model.definition,
      sentence: model.sentence,
      learnCount: model.learn,
      synonyms: model.synonyms,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt: DateTime.parse(model.updatedAt),
    );
  }

  static WordModel toModel(Word entity) {
    return WordModel(
      id: entity.id,
      word: entity.word,
      partOfSpeech: entity.partOfSpeech,
      phonetic: entity.phonetic,
      definition: entity.definition,
      sentence: entity.sentence,
      learn: entity.learnCount,
      synonyms: entity.synonyms,
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

  static WordDef toWordDefEntity(Map<String, dynamic> map) {
    return WordDef(
      id: map['id'],
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
    );
  }

  static List<WordSummary> toSummaryList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => toSummaryEntity(map)).toList();
  }

  static List<WordDef> toWordDefList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => toWordDefEntity(map)).toList();
  }

  static WordWithImage toWordWithImage(Map<String, dynamic> map) {
    return WordWithImage(
      id: map['id'],
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
      tinyImageUrl: map['tinyImageUrl'],
      learn: map['learn'],
      hasTranslation: (map['translationCount'] as int? ?? 0) > 0,
      hasSentence:
          map['sentence'] != null && (map['sentence'] as String).isNotEmpty,
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
      partOfSpeech: map['partOfSpeech'] as String,
      phonetic: map['phonetic'] as String,
      definition: map['definition'] as String,
      sentence: map['sentence'],
      learnCount: map['learn'] as int? ?? 0,
      synonyms: map['synonyms'] as String? ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static FlashcardWord toFlashcardWord(Map<String, dynamic> map) {
    return FlashcardWord(
      id: map['id'] as int,
      word: map['word'] as String,
      phonetic: map['phonetic'] as String? ?? '',
      definition: map['definition'] as String,
      sentence: map['sentence'],
      learnCount: map['learn'],
    );
  }

  static Map<String, String> toMapInsertion(WordInsertion word) {
    return {
      'word': word.word,
      'definition': word.definition,
      'sentence': word.sentence,
      'phonetic': word.phonetic,
    };
  }
}
