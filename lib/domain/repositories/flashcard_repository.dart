import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_meaning.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
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
}
