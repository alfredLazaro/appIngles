/// Caso de uso: Validar si la respuesta es correcta
class ValidateWordAnswer {
  bool call(String userAnswer, String correctWord) {
    return userAnswer.trim().toLowerCase() == correctWord.trim().toLowerCase();
  }
}
