import 'package:first_app/domain/repositories/word_repository.dart';

class DeleteWordUseCase {
  final WordRepository _repository;

  DeleteWordUseCase(this._repository);

  Future<void> call(int word_id) async {
    if (word_id <= 0) {
      throw Exception('ID de palabra inválido');
    }
    return await _repository.deleteWord(word_id);
  }
}
