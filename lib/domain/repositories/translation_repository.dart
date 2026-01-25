// domain/repositories/translation_repository.dart
abstract class TranslationRepository {
  Future<int> insertTranslation(Map<String, dynamic> translation);
  Future<List<int>> insertTranslations(int wordId, List<Map<String, dynamic>> translations);
  Future<List<Map<String, dynamic>>> getTranslationsByWordId(int wordId);
  Future<Map<String, dynamic>?> getTranslationById(int id);
  Future<int> updateTranslation(int id, Map<String, dynamic> translation);
  Future<int> deleteTranslation(int id);
  Future<int> deleteTranslationsByWordId(int wordId);
  Future<List<Map<String, dynamic>>> getAllTranslations();
  Future<List<Map<String, dynamic>>> getTranslationsWithWordDetails(int wordId);
  Future<List<Map<String, dynamic>>> searchTranslations(String searchTerm);
  Future<int> getTranslationCount(int wordId);
  Future<void> batchInsertTranslations(List<Map<String, dynamic>> translations);
  Future<int> upsertTranslation(Map<String, dynamic> translation);
}