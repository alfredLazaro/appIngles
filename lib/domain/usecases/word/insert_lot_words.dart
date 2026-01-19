// domain/usecases/word/insert_lot_words.dart
import 'package:first_app/domain/entities/word_insertion.dart';
import 'package:first_app/domain/repositories/word_repository.dart';

class InsertLotWordsUseCase {
  final WordRepository _repository;

  InsertLotWordsUseCase(this._repository);

  Future<List<Map<String, dynamic>>> call(List<WordInsertion> words) async {
    return await _repository.insertLotWords(words);
  }
}
