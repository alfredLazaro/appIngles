import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/paginated_result.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_meaning.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/domain/entities/word_with_image.dart';

/// Contrato del repositorio de palabras
abstract class WordRepository {
  Future<List<WordSummary>> getRecentWordsSummary({int limit = 9});
  Future<int> saveWord(Word word);
  Future<void> updateSentence(int wordId, String newSentence);
  Future<void> deleteWord(int wordId);
  Future<List<WordMeaning>> searchWordMeanings(String word);
  Future<void> updateLearnCount(int wordId, int newLearn);
  // New methods based on your DAO
  Future<Word?> getWordById(int id);
  Future<bool> wordExists(String wordText);
  Future<List<WordWithImage>> getAllWordsWithImages();
  Future<PaginatedResult<WordWithImage>> getWordsWithImagesPaginated({
    required int page,
    int pageSize,
    String? searchQuery,
  });
  Future<List<FlashcardWord>> getWordsForPractice(int limit);
  Future<List<String>> getSentencesForPractice({int limit});
  Future<List<Word>> searchWords(String query);
  Future<int> getTotalWordCount();
  Future<void> batchUpdateLearnCounts(Map<int, int> updates);
  Future<List<Word>> getAllWords();
  Future<void> updateWord(Word word);
  Future<int> countSentences();
}
