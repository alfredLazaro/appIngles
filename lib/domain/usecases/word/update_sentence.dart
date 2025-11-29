import 'package:first_app/domain/repositories/word_repository.dart';

class UpdateSentenceUseCase {
  final WordRepository _repository;

  UpdateSentenceUseCase(this._repository);

  Future<void> call(int wordId, String newSentence) async {
    final sentence = newSentence.trim();
    if (sentence.isEmpty) {
      throw Exception('La oración no puede estar vacía');
    }
    return await _repository.updateSentence(wordId, sentence);
  }
}
