// domain/repositories/translation_repository.dart
import 'package:first_app/domain/entities/translation_entity.dart';

abstract class TranslationRepository {
  Future<List<TranslationEntity>> getTranslationsByWordId(int wordId);
  Future<List<TranslationEntity>> getAllTranslations();
  Future<List<TranslationEntity>> searchTranslations(String searchTerm);
  Future<TranslationEntity?> getTranslationById(int id);

  Future<int> insertTranslation(int wordId, String wordTranslate, List<String> alternatives);
  Future<List<int>> insertTranslations(int wordId, List<TranslationEntity> translations);
  Future<int> updateTranslation(int id, String? wordTranslate, List<String>? alternatives);
  Future<int> deleteTranslation(int id);
  Future<int> deleteTranslationsByWordId(int wordId);

  Future<int> getTranslationCount(int wordId);
  Future<List<Map<String, dynamic>>> getTranslationsWithWordDetails(int wordId);
}