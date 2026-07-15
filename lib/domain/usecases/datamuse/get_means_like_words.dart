import 'package:first_app/domain/entities/related_word.dart';
import 'package:first_app/domain/repositories/datamuse_repository.dart';

class GetMeansLikeWordsUseCase {
  final DatamuseRepository _repository;

  GetMeansLikeWordsUseCase(this._repository);

  Future<List<RelatedWord>> call(String word) async {
    if (word.trim().isEmpty) {
      throw Exception('La palabra no puede estar vacía');
    }
    return await _repository.getMeansLike(word);
  }
}
