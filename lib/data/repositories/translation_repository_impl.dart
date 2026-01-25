// data/repositories/translation_repository_impl.dart
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/data/datasources/local/translation_dao.dart';
import 'package:first_app/data/mappers/translation_mapper.dart';
import 'package:first_app/domain/entities/translation.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationDao _translationDao;
  final TranslationMapper _mapper = TranslationMapper();

  TranslationRepositoryImpl({required TranslationDao translationDao})
      : _translationDao = translationDao;

  @override
  Future<int> insertTranslation(Map<String, dynamic> translation) async {
    return await _translationDao.insertTranslation(translation);
  }

  @override
  Future<List<int>> insertTranslations(
    int wordId,
    List<Map<String, dynamic>> translations,
  ) async {
    return await _translationDao.insertTranslations(wordId, translations);
  }

  @override
  Future<List<Map<String, dynamic>>> getTranslationsByWordId(
    int wordId,
  ) async {
    return await _translationDao.getTranslationsByWordId(wordId);
  }

  @override
  Future<Map<String, dynamic>?> getTranslationById(int id) async {
    return await _translationDao.getTranslationById(id);
  }

  @override
  Future<int> updateTranslation(
    int id,
    Map<String, dynamic> translation,
  ) async {
    return await _translationDao.updateTranslation(id, translation);
  }

  @override
  Future<int> deleteTranslation(int id) async {
    return await _translationDao.deleteTranslation(id);
  }

  @override
  Future<int> deleteTranslationsByWordId(int wordId) async {
    return await _translationDao.deleteTranslationsByWordId(wordId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllTranslations() async {
    return await _translationDao.getAllTranslations();
  }

  @override
  Future<List<Map<String, dynamic>>> getTranslationsWithWordDetails(
    int wordId,
  ) async {
    return await _translationDao.getTranslationsWithWordDetails(wordId);
  }

  @override
  Future<List<Map<String, dynamic>>> searchTranslations(
    String searchTerm,
  ) async {
    return await _translationDao.searchTranslations(searchTerm);
  }

  @override
  Future<int> getTranslationCount(int wordId) async {
    return await _translationDao.getTranslationCount(wordId);
  }

  @override
  Future<void> batchInsertTranslations(
    List<Map<String, dynamic>> translations,
  ) async {
    await _translationDao.batchInsertTranslations(translations);
  }

  @override
  Future<int> upsertTranslation(Map<String, dynamic> translation) async {
    return await _translationDao.upsertTranslation(translation);
  }

  // Additional helper methods that work with entities

  Future<List<Translation>> getTranslationEntitiesByWordId(int wordId) async {
    final results = await _translationDao.getTranslationsByWordId(wordId);
    return _mapper.mapToEntityList(results);
  }

  Future<Translation?> getTranslationEntityById(int id) async {
    final result = await _translationDao.getTranslationById(id);
    if (result == null) return null;
    return _mapper.mapToEntity(result);
  }

  Future<int> insertTranslationEntity(Translation translation) async {
    final map = _mapper.mapToDatabase(translation);
    return await _translationDao.insertTranslation(map);
  }

  Future<List<int>> insertTranslationEntities(
    int wordId,
    List<Translation> translations,
  ) async {
    final maps = translations.map((t) => _mapper.mapToDatabase(t)).toList();
    return await _translationDao.insertTranslations(wordId, maps);
  }
}