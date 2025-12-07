import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_meaning.dart';
import 'package:first_app/domain/entities/word_sumary.dart';

/// Contrato del repositorio de palabras
abstract class WordRepository {
  //Future<List<Word>> getRecentWords({int limit = 10});
  Future<List<WordSummary>> getRecentWordsSummary({int limit = 9});
  Future<int> saveWord(Word word);
  Future<void> updateSentence(int wordId, String newSentence);
  Future<void> deleteWord(int wordId);
  Future<List<WordMeaning>> searchWordMeanings(String word);
  Future<void> updateLearnCount(int wordId, int newLearn);
}
