abstract class ITtsService {
  Future<void> initialize({
    String language = 'en-US',
    double pitch = 1.0,
    double speechRate = 0.5,
    double volume = 1.0,
  });
  Future<void> speak(String text);
  Future<void> stop();
  Future<bool> get isSpeaking;
  Future<void> setLanguage(String language);
  void dispose();
}
