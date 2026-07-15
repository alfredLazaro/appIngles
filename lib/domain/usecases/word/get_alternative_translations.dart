import 'package:first_app/data/services/mlkit_translation_service.dart';
import 'package:first_app/domain/usecases/datamuse/get_means_like_words.dart';

class GetAlternativeTranslationsUseCase {
  final GetMeansLikeWordsUseCase _getMeansLikeWords;
  final MlKitTranslationService _mlKitTranslationService;

  GetAlternativeTranslationsUseCase(
    this._getMeansLikeWords,
    this._mlKitTranslationService,
  );

  Future<Map<String, String>> call(String word) async {
    try {
      final relatedWords = await _getMeansLikeWords(word);
      final englishWords = relatedWords
          .take(5)
          .map((rw) => rw.word)
          .where((w) => w.toLowerCase() != word.toLowerCase())
          .toList();

      if (englishWords.isEmpty) return {};

      final spanishTranslations = await _mlKitTranslationService.translateBatch(englishWords);

      final result = <String, String>{};
      for (int i = 0; i < englishWords.length; i++) {
        result[englishWords[i]] = spanishTranslations[i];
      }
      return result;
    } catch (_) {
      return {};
    }
  }
}
