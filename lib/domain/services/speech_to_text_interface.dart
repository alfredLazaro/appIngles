abstract class ISpeechToTextService {
  bool get isListening;
  Future<void> startListening({
    required Function(String) onResult,
  });
  Future<void> stopListening();
  void dispose();
}
