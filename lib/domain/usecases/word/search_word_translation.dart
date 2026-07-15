import 'package:first_app/domain/repositories/word_repository.dart';

class SearchWordTranslationUseCase {
  final WordRepository _repository;

  SearchWordTranslationUseCase(this._repository);

  Future<Map<String, dynamic>?> call(String word) async {
    try {
      return await _repository.fetchTranslation(word);
    } catch (_) {
      return null;
    }
  }
}
