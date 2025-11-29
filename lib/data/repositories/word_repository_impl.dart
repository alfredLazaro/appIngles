import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_meaning.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/core/services/dictonary_service.dart';
import 'package:first_app/data/mappers/word_mapper.dart';

/// Implementación concreta del repositorio
class WordRepositoryImpl implements WordRepository {
  final WordDao _wordDao;
  final WordService _wordService;

  WordRepositoryImpl({
    required WordDao wordDao,
    required WordService wordService,
  })  : _wordDao = wordDao,
        _wordService = wordService;

/*   @override
  Future<List<Word>> getRecentWords({int limit = 10}) async {
    final models = await _wordDao.getLastPfIngBasic();
    return WordMapper.toEntityList(models);
  } */

  @override
  Future<List<WordSummary>> getRecentWordsSummary({int limit = 9}) async {
    final models = await _wordDao.getLastPfIngBasic();
    return WordMapper.toSummaryList(models);
  }

  @override
  Future<int> saveWord(Word word) async {
    final model = WordMapper.toModel(word);
    return await _wordDao.insertWord(model);
  }

  @override
  Future<void> updateSentence(int wordId, String newSentence) async {
    await _wordDao.updateSentence(wordId, newSentence);
  }

  @override
  Future<void> deleteWord(int wordId) async {
    await _wordDao.deletePfIng(wordId);
  }

  @override
  Future<List<WordMeaning>> searchWordMeanings(String word) async {
    try {
      final data = await _wordService.getAllMeanings(word);
      return data.map((meaning) {
        final definitions = (meaning['definitions'] as List)
            .map((def) => WordDefinition(
                  definition: def['definition'] ?? '',
                  example: def['example'],
                ))
            .toList();

        return WordMeaning(
          partOfSpeech: meaning['partOfSpeech'] ?? 'N/A',
          definitions: definitions,
        );
      }).toList();
    } catch (e) {
      throw Exception('Error al buscar definiciones: $e');
    }
  }
}
