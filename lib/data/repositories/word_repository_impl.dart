import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_meaning.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/domain/entities/paginated_result.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/data/datasources/local/word_dao.dart';
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

  // ============ EXISTING METHODS ============

  @override
  Future<List<WordSummary>> getRecentWordsSummary({int limit = 9}) async {
    try {
      final models = await _wordDao.getLastWordBasic();
      return WordMapper.toSummaryList(models);
    } catch (e) {
      throw Exception('Error al obtener palabras recientes: $e');
    }
  }

  @override
  Future<int> saveWord(Word word) async {
    try {
      final model = WordMapper.toModel(word);
      return await _wordDao.insertWord(model);
    } catch (e) {
      throw Exception('Error al guardar palabra: $e');
    }
  }

  @override
  Future<void> updateSentence(int wordId, String newSentence) async {
    try {
      await _wordDao.updateSentence(wordId, newSentence);
    } catch (e) {
      throw Exception('Error al actualizar oración: $e');
    }
  }

  @override
  Future<void> deleteWord(int wordId) async {
    try {
      await _wordDao.deleteWord(wordId);
    } catch (e) {
      throw Exception('Error al eliminar palabra: $e');
    }
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

  @override
  Future<void> updateLearnCount(int wordId, int newLearn) async {
    try {
      await _wordDao.updateLearn(wordId, newLearn);
    } catch (e) {
      throw Exception('Error al actualizar conteo de aprendizaje: $e');
    }
  }

  // ============ NEW METHODS BASED ON YOUR DAO ============

  @override
  Future<Word?> getWordById(int id) async {
    try {
      final model = await _wordDao.getWordById(id);
      return model != null ? WordMapper.toEntity(model) : null;
    } catch (e) {
      throw Exception('Error al obtener palabra por ID: $e');
    }
  }

  @override
  Future<bool> wordExists(String wordText) async {
    try {
      return await _wordDao.wordExists(wordText);
    } catch (e) {
      throw Exception('Error al verificar si la palabra existe: $e');
    }
  }

  @override
  Future<List<WordWithImage>> getAllWordsWithImages() async {
    try {
      final maps = await _wordDao.getAllWordsWithImages();
      return maps.map((map) => WordMapper.toWordWithImage(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener palabras con imágenes: $e');
    }
  }

  @override
  Future<PaginatedResult<WordWithImage>> getWordsWithImagesPaginated({
    required int page,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      final maps = await _wordDao.getWordsWithImagesPaginated(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );

      // Since you don't have countAllWordsWithImages in DAO, we'll estimate
      // For now, if we get less than pageSize items, there's no next page
      final hasNextPage = maps.length == pageSize;

      return PaginatedResult(
        items: maps.map((map) => WordMapper.toWordWithImage(map)).toList(),
        currentPage: page,
        pageSize: pageSize,
        totalItems: 0, // Can't calculate without count method
        hasNextPage: hasNextPage,
      );
    } catch (e) {
      throw Exception('Error en paginación de palabras con imágenes: $e');
    }
  }

  @override
  Future<List<FlashcardWord>> getWordsForPractice(int limit) async {
    try {
      final maps = await _wordDao.getWordsForPractice(limit);
      return maps.map((map) => WordMapper.toFlashcardWord(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener palabras para practicar: $e');
    }
  }

  @override
  Future<List<String>> getSentencesForPractice({int limit = 10}) async {
    try {
      final maps = await _wordDao.getSentencesForPractice(limit);
      return maps
          .where((map) => map['sentence'] != null)
          .map((map) => map['sentence'] as String)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener oraciones para practicar: $e');
    }
  }

  @override
  Future<List<Word>> searchWords(String query) async {
    try {
      final models = await _wordDao.searchWords(query);
      return WordMapper.toEntityList(models);
    } catch (e) {
      throw Exception('Error al buscar palabras: $e');
    }
  }

  @override
  Future<int> getTotalWordCount() async {
    try {
      return await _wordDao.countWords();
    } catch (e) {
      throw Exception('Error al contar palabras: $e');
    }
  }

  @override
  Future<void> batchUpdateLearnCounts(Map<int, int> updates) async {
    try {
      await _wordDao.batchUpdateLearnCounts(updates);
    } catch (e) {
      throw Exception('Error en actualización por lotes: $e');
    }
  }

  @override
  Future<List<Word>> getAllWords() async {
    try {
      final models = await _wordDao.getAllWords();
      return WordMapper.toEntityList(models);
    } catch (e) {
      throw Exception('Error al obtener todas las palabras: $e');
    }
  }

  @override
  Future<void> updateWord(Word word) async {
    try {
      final model = WordMapper.toModel(word);
      await _wordDao.updateWord(model);
    } catch (e) {
      throw Exception('Error al actualizar palabra: $e');
    }
  }
}
