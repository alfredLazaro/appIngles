// data/repositories/translation_repository_impl.dart
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/data/datasources/local/translation_dao.dart';
import 'package:first_app/data/mappers/translation_mapper.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationDao _translationDao;
  final TranslationMapper _mapper = TranslationMapper();

  TranslationRepositoryImpl({required TranslationDao translationDao})
      : _translationDao = translationDao;

  @override
  Future<List<TranslationEntity>> getTranslationsByWordId(
    int wordId,
  ) async {
    final results = await _translationDao.getTranslationsByWordId(wordId);
    return _mapper.mapToTranslationEntityList(results);
  }

  @override
  Future<List<TranslationEntity>> getAllTranslations() async {
    final results = await _translationDao.getAllTranslations();
    return _mapper.mapToTranslationEntityList(results);
  }

  @override
  Future<List<TranslationEntity>> searchTranslations(
    String searchTerm,
  ) async {
    final results = await _translationDao.searchTranslations(searchTerm);
    return _mapper.mapToTranslationEntityList(results);
  }

  @override
  Future<TranslationEntity?> getTranslationById(int id) async {
    final result = await _translationDao.getTranslationById(id);
    if (result == null) return null;
    return _mapper.mapToTranslationEntity(result);
  }

  @override
  Future<int> insertTranslation(
    int wordId,
    String wordTranslate,
    List<String> alternatives,
  ) async {
    final map = {
      'wordId': wordId,
      'wordTranslate': wordTranslate,
      'alternatives': alternatives.join('|'),
    };
    return await _translationDao.insertTranslation(map);
  }

  @override
  Future<List<int>> insertTranslations(
    int wordId,
    List<TranslationEntity> translations,
  ) async {
    final maps = translations
        .map((t) => _mapper.translationEntityToMap(t))
        .toList();
    return await _translationDao.insertTranslations(wordId, maps);
  }

  @override
  Future<int> updateTranslation(
    int id,
    String? wordTranslate,
    List<String>? alternatives,
  ) async {
    final map = <String, dynamic>{};
    if (wordTranslate != null) {
      map['wordTranslate'] = wordTranslate;
    }
    if (alternatives != null) {
      map['alternatives'] = alternatives.join('|');
    }
    return await _translationDao.updateTranslation(id, map);
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
  Future<int> getTranslationCount(int wordId) async {
    return await _translationDao.getTranslationCount(wordId);
  }

  @override
  Future<List<Map<String, dynamic>>> getTranslationsWithWordDetails(
    int wordId,
  ) async {
    return await _translationDao.getTranslationsWithWordDetails(wordId);
  }
}