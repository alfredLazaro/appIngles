import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/repositories/word_repository.dart';

class SaveWordUseCase {
  final WordRepository _repository;

  SaveWordUseCase(this._repository);

  Future<int> call(Word word) async {
    if (word.word.trim().isEmpty) {
      throw Exception('La palabra no puede estar vacía');
    }

    if (word.definition.trim().isEmpty) {
      throw Exception('La definición no puede estar vacía');
    }

    return await _repository.saveWord(word);
  }
}
