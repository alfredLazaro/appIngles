import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/repositories/word_repository.dart';

class GetRecentWordsUseCase {
  final WordRepository _repository;

  GetRecentWordsUseCase(this._repository);

  Future<List<Word>> call({int limit = 9}) async {
    return await _repository.getRecentWords(limit: limit);
  }
}
