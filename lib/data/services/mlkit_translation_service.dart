import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MlKitTranslationService {
  OnDeviceTranslator? _translator;

  OnDeviceTranslator _getTranslator() {
    _translator ??= OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.spanish,
    );
    return _translator!;
  }

  Future<Map<String, dynamic>> translate(String text) async {
    final translator = _getTranslator();
    final translatedText = await translator.translateText(text);
    return {
      'translatedText': translatedText,
      'alternatives': <String>[],
    };
  }

  Future<List<String>> translateBatch(List<String> texts) async {
    final translator = _getTranslator();
    final results = await Future.wait(
      texts.map((t) => translator.translateText(t)),
    );
    return results.toList();
  }

  void dispose() {
    _translator?.close();
    _translator = null;
  }
}
