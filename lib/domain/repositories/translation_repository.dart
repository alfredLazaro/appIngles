// domain/repositories/translation_repository.dart
import 'package:first_app/domain/entities/translation_entity.dart';

abstract class TranslationRepository {
  Future<List<TranslationEntity>> getTranslationsByword_ids(List<int> word_ids);
  Future<List<TranslationEntity>> getTranslationsByword_id(int word_id);
  Future<List<TranslationEntity>> getAllTranslations();
  Future<List<TranslationEntity>> searchTranslations(String searchTerm);
  Future<TranslationEntity?> getTranslationById(int id);

  Future<int> insertTranslation(int word_id, String wordTranslate, List<String> alternatives);
  Future<List<int>> insertTranslations(int word_id, List<TranslationEntity> translations);
  Future<int> updateTranslation(int id, String? wordTranslate, List<String>? alternatives);
  Future<int> deleteTranslation(int id);
  Future<int> deleteTranslationsByword_id(int word_id);

  Future<int> getTranslationCount(int word_id);
  Future<List<Map<String, dynamic>>> getTranslationsWithWordDetails(int word_id);
}