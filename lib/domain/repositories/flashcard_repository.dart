import 'package:first_app/data/datasources/local/word_dao.dart';
import 'package:first_app/domain/entities/paginated_result.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_meaning.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/domain/repositories/word_repository.dart';

/// Repositorio especializado solo para operaciones de flashcards
/// Implementa solo los métodos necesarios para flashcards
class FlashcardRepository implements WordRepository {
  final WordDao _wordDao;

  FlashcardRepository({required WordDao wordDao}) : _wordDao = wordDao;

  /// ✅ MÉTODO NECESARIO: Actualizar contador de aprendizaje
  @override
  Future<void> updateLearnCount(int wordId, int newLearn) async {
    await _wordDao.updateLearn(wordId, newLearn);
  }
  // ❌ MÉTODOS NO NECESARIOS para flashcards (implementación mínima)

  @override
  Future<List<WordSummary>> getRecentWordsSummary({int limit = 9}) {
    // No necesario para flashcards
    return Future.value([]);
  }

  @override
  Future<int> saveWord(Word word) {
    // No necesario para flashcards
    return Future.value(0);
  }

  @override
  Future<void> updateSentence(int wordId, String newSentence) {
    // No necesario para flashcards
    return Future.value();
  }

  @override
  Future<void> deleteWord(int wordId) {
    // No necesario para flashcards
    return Future.value();
  }

  @override
  Future<List<WordMeaning>> searchWordMeanings(String word) {
    // No necesario para flashcards
    return Future.value([]);
  }

  @override
  Future<void> batchUpdateLearnCounts(Map<int, int> updates) {
    // TODO: implement batchUpdateLearnCounts
    throw UnimplementedError();
  }

  @override
  Future<List<Word>> getAllWords() {
    // TODO: implement getAllWords
    throw UnimplementedError();
  }

  @override
  Future<List<WordWithImage>> getAllWordsWithImages() {
    // TODO: implement getAllWordsWithImages
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getSentencesForPractice({int limit = 10}) {
    // TODO: implement getSentencesForPractice
    throw UnimplementedError();
  }

  @override
  Future<int> getTotalWordCount() {
    // TODO: implement getTotalWordCount
    throw UnimplementedError();
  }

  @override
  Future<Word?> getWordById(int id) {
    // TODO: implement getWordById
    throw UnimplementedError();
  }

  @override
  Future<List<Word>> getWordsForPractice({int limit = 10}) {
    // TODO: implement getWordsForPractice
    throw UnimplementedError();
  }

  @override
  Future<PaginatedResult<WordWithImage>> getWordsWithImagesPaginated(
      {required int page, int pageSize = 10, String? searchQuery}) {
    // TODO: implement getWordsWithImagesPaginated
    throw UnimplementedError();
  }

  @override
  Future<List<Word>> searchWords(String query) {
    // TODO: implement searchWords
    throw UnimplementedError();
  }

  @override
  Future<void> updateWord(Word word) {
    // TODO: implement updateWord
    throw UnimplementedError();
  }

  @override
  Future<bool> wordExists(String wordText) {
    // TODO: implement wordExists
    throw UnimplementedError();
  }
}
