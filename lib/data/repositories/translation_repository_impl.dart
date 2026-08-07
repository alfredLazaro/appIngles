// data/repositories/translation_repository_impl.dart
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/data/datasources/local/db_constants.dart';
import 'package:first_app/data/datasources/local/translation_dao.dart';
import 'package:first_app/data/mappers/translation_mapper.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationDao _translationDao;
  final TranslationMapper _mapper = TranslationMapper();

  TranslationRepositoryImpl({required TranslationDao translationDao})
      : _translationDao = translationDao;

  @override
  Future<List<TranslationEntity>> getTranslationsByword_ids(
    List<int> word_ids,
  ) async {
    final results = await _translationDao.getTranslationsByword_ids(word_ids);
    return _mapper.mapToTranslationEntityList(results);
  }

  @override
  Future<List<TranslationEntity>> getTranslationsByword_id(
    int word_id,
  ) async {
    final results = await _translationDao.getTranslationsByword_id(word_id);
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
    int word_id,
    String wordTranslate,
    List<String> alternatives,
  ) async {
    final map = {
      TranslationFields.word_id: word_id,
      TranslationFields.wordTranslate: wordTranslate,
      TranslationFields.alternatives: alternatives.join('|'),
    };
    return await _translationDao.insertTranslation(map);
  }

  @override
  Future<List<int>> insertTranslations(
    int word_id,
    List<TranslationEntity> translations,
  ) async {
    final maps = translations
        .map((t) => _mapper.translationEntityToMap(t))
        .toList();
    return await _translationDao.insertTranslations(word_id, maps);
  }

  @override
  Future<int> updateTranslation(
    int id,
    String? wordTranslate,
    List<String>? alternatives,
  ) async {
    final map = <String, dynamic>{};
    if (wordTranslate != null) {
      map[TranslationFields.wordTranslate] = wordTranslate;
    }
    if (alternatives != null) {
      map[TranslationFields.alternatives] = alternatives.join('|');
    }
    return await _translationDao.updateTranslation(id, map);
  }

  @override
  Future<int> deleteTranslation(int id) async {
    return await _translationDao.deleteTranslation(id);
  }

  @override
  Future<int> deleteTranslationsByword_id(int word_id) async {
    return await _translationDao.deleteTranslationsByword_id(word_id);
  }

  @override
  Future<int> getTranslationCount(int word_id) async {
    return await _translationDao.getTranslationCount(word_id);
  }

  @override
  Future<List<Map<String, dynamic>>> getTranslationsWithWordDetails(
    int word_id,
  ) async {
    return await _translationDao.getTranslationsWithWordDetails(word_id);
  }
}