import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/insertion_result.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_filter.dart';
import 'package:first_app/domain/entities/word_insertion.dart';
import 'package:first_app/domain/entities/word_meaning.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/domain/entities/paginated_result.dart';
import 'package:first_app/domain/entities/word_def.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/data/datasources/local/word_crud_dao.dart';
import 'package:first_app/data/datasources/local/word_practice_dao.dart';
import 'package:first_app/data/datasources/local/word_batch_dao.dart';
import 'package:first_app/data/datasources/remote/dictionary_service.dart';
import 'package:first_app/data/mappers/word_mapper.dart';
import 'package:first_app/data/services/mlkit_translation_service.dart';
import 'package:first_app/domain/entities/sentence_model.dart';

/// Implementación concreta del repositorio
class WordRepositoryImpl implements WordRepository {
  final WordCrudDao _wordCrudDao;
  final WordPracticeDao _wordPracticeDao;
  final WordBatchDao _wordBatchDao;
  final WordService _wordService;
  final MlKitTranslationService _mlKitTranslationService;

  WordRepositoryImpl({
    required WordCrudDao wordCrudDao,
    required WordPracticeDao wordPracticeDao,
    required WordBatchDao wordBatchDao,
    required WordService wordService,
    required MlKitTranslationService mlKitTranslationService,
  })  : _wordCrudDao = wordCrudDao,
        _wordPracticeDao = wordPracticeDao,
        _wordBatchDao = wordBatchDao,
        _wordService = wordService,
        _mlKitTranslationService = mlKitTranslationService;

  // ============ EXISTING METHODS ============

  @override
  Future<List<WordSummary>> getRecentWordsSummary({int limit = 9}) async {
    try {
      final models = await _wordCrudDao.getLastWordBasic(limit: limit);
      return WordMapper.toSummaryList(models);
    } catch (e) {
      throw Exception('Error al obtener palabras recientes: $e');
    }
  }

  @override
  Future<int> saveWord(Word word) async {
    try {
      final model = WordMapper.toModel(word);
      return await _wordCrudDao.insertWord(model);
    } catch (e) {
      throw Exception('Error al guardar palabra: $e');
    }
  }

  @override
  Future<void> updateSentence(int wordId, String newSentence) async {
    try {
      await _wordCrudDao.updateSentence(wordId, newSentence);
    } catch (e) {
      throw Exception('Error al actualizar oración: $e');
    }
  }

  @override
  Future<void> deleteWord(int wordId) async {
    try {
      await _wordCrudDao.deleteWord(wordId);
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
                  phonetic: def['phonetic'] ?? '',
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
      await _wordPracticeDao.updateLearn(wordId, newLearn);
    } catch (e) {
      throw Exception('Error al actualizar conteo de aprendizaje: $e');
    }
  }

  // ============ NEW METHODS BASED ON YOUR DAO ============

  @override
  Future<Word?> getWordById(int id) async {
    try {
      final model = await _wordCrudDao.getWordById(id);
      return model != null ? WordMapper.toEntity(model) : null;
    } catch (e) {
      throw Exception('Error al obtener palabra por ID: $e');
    }
  }

  @override
  Future<bool> wordExists(String wordText) async {
    try {
      return await _wordCrudDao.wordExists(wordText);
    } catch (e) {
      throw Exception('Error al verificar si la palabra existe: $e');
    }
  }

  @override
  Future<List<WordWithImage>> getAllWordsWithImages() async {
    try {
      final maps = await _wordBatchDao.getAllWordsWithImages();
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
    WordFilterMode? filterMode,
  }) async {
    try {
      final maps = await _wordBatchDao.getWordsWithImagesPaginated(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        filterMode: filterMode,
      );

      // Since you don't have countAllWordsWithImages in DAO, we'll estimate
      // For now, if we get less than pageSize items, there's no next page
      final hasNextPage = maps.length == pageSize;

      return PaginatedResult(
        items: maps.map((map) => WordMapper.toWordWithImage(map)).toList(),
        currentPage: page,
        pageSize: pageSize,
        totalItems: await getTotalWordCount(), // total words
        hasNextPage: hasNextPage,
      );
    } catch (e) {
      throw Exception('Error en paginación de palabras con imágenes: $e');
    }
  }

  @override
  Future<List<FlashcardWord>> getWordsForPractice(int limit) async {
    try {
      final maps = await _wordPracticeDao.getWordsForPractice(limit);
      return maps.map((map) => WordMapper.toFlashcardWord(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener palabras para practicar: $e');
    }
  }

  @override
  Future<List<SentenceModel>> getSentencesForPractice({int limit = 10}) async {
    try {
      final maps = await _wordPracticeDao.getSentencesForPractice(limit);
      return maps
          .where((map) => map['sentence'] != null)
          .map((map) => SentenceModel.fromMap(map))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener oraciones para practicar: $e');
    }
  }

  @override
  Future<List<WordDef>> gettWordDefForPractice(int limit) async {
    try {
      final maps = await _wordPracticeDao.gettWordDefForPractice(limit);
      return WordMapper.toWordDefList(maps);
    } catch (e) {
      throw Exception('Error al obtener oraciones para practicar: $e');
    }
  }

  @override
  Future<List<Word>> searchWords(String query) async {
    try {
      final models = await _wordCrudDao.searchWords(query);
      return WordMapper.toEntityList(models);
    } catch (e) {
      throw Exception('Error al buscar palabras: $e');
    }
  }

  @override
  Future<int> getTotalWordCount() async {
    try {
      return await _wordCrudDao.countWords();
    } catch (e) {
      throw Exception('Error al contar palabras: $e');
    }
  }

  @override
  Future<void> batchUpdateLearnCounts(Map<int, int> updates) async {
    try {
      await _wordBatchDao.batchUpdateLearnCounts(updates);
    } catch (e) {
      throw Exception('Error en actualización por lotes: $e');
    }
  }

  @override
  Future<List<Word>> getRecentWords({int limit = 9}) async {
    try {
      final models = await _wordCrudDao.getLastWords(limit: limit);
      return WordMapper.toEntityList(models);
    } catch (e) {
      throw Exception('Error al obtener palabras recientes: $e');
    }
  }

  @override
  Future<List<Word>> getAllWords() async {
    try {
      final models = await _wordCrudDao.getAllWords();
      return WordMapper.toEntityList(models);
    } catch (e) {
      throw Exception('Error al obtener todas las palabras: $e');
    }
  }

  @override
  Future<void> updateWord(Word word) async {
    try {
      final model = WordMapper.toModel(word);
      await _wordCrudDao.updateWord(model);
    } catch (e) {
      throw Exception('Error al actualizar palabra: $e');
    }
  }

  @override
  Future<int> countSentences() async {
    return await _wordPracticeDao.countSentences();
  }

  @override
  Future<List<int>> getAllLearnCounts() async {
    return await _wordBatchDao.getAllLearnCounts();
  }

  @override
  Future<Map<String, dynamic>?> fetchTranslation(String word) async {
    try {
      return await _mlKitTranslationService.translate(word);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<InsertionResult>> insertLotWords(
      List<WordInsertion> words) async {
    List<Map<String, String>> ls =
        words.map((word) => WordMapper.toMapInsertion(word)).toList();
    final list = await _wordBatchDao.insertLotWords(ls);
    return list
        .map((map) => InsertionResult(
              id: map['id'] as int,
              word: map['word'] as String,
            ))
        .toList();
  }
}
