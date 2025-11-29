import 'package:first_app/domain/repositories/word_repository.dart';

class DeleteWordUseCase {
  final WordRepository _repository;

  DeleteWordUseCase(this._repository);

  Future<void> call(int wordId) async {
    if (wordId <= 0) {
      throw Exception('ID de palabra inválido');
    }
    return await _repository.deleteWord(wordId);
  }
}
