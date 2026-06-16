import 'package:first_app/domain/entities/word_meaning.dart';
import 'package:first_app/domain/repositories/word_repository.dart';

class SearchWordDefinitionUseCase {
  final WordRepository _repository;

  SearchWordDefinitionUseCase(this._repository);

  Future<List<WordMeaning>> call(String word) async {
    bool existe = await _repository.wordExists(word);
    if (existe) {
      throw Exception('La palabra ya existe');
    }
    if (word.trim().isEmpty) {
      throw Exception('Debe ingresar una palabra');
    }
    return await _repository.searchWordMeanings(word);
  }
}
