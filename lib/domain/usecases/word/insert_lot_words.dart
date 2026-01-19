// domain/usecases/word/insert_lot_words.dart
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/repositories/word_repository.dart';

class InsertLotWordsUseCase {
  final WordRepository _repository;

  InsertLotWordsUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call(List<Word> words) async {
    return await _repository.insertLotWords(words);
  }
}
