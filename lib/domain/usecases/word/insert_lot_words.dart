import 'package:first_app/domain/entities/insertion_result.dart';
import 'package:first_app/domain/entities/word_insertion.dart';
import 'package:first_app/domain/repositories/word_repository.dart';

class InsertLotWordsUseCase {
  final WordRepository _repository;

  InsertLotWordsUseCase(this._repository);

  Future<List<InsertionResult>> call(List<WordInsertion> words) async {
    return await _repository.insertLotWords(words);
  }
}
