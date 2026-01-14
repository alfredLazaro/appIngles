// practice_data.dart
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';

abstract class PracticeData {
  const PracticeData();
}

// For Flashcard practice
class FlashcardPracticeData extends PracticeData {
  final List<FlashcardWord> words;
  final Map<int, List<FlashcardImage>> imagesMap;
  
  const FlashcardPracticeData({
    required this.words,
    required this.imagesMap,
  });
}

// For Sentence practice
class SentencePracticeData extends PracticeData {
  final List<SentenceModel> sentences;
  
  const SentencePracticeData({
    required this.sentences,
  });
}

// Sentence model for practice
class SentenceModel {
  final int id;
  final String sentence;
  
  const SentenceModel({
    required this.id,
    required this.sentence,
  });
  
  factory SentenceModel.fromMap(Map<String, dynamic> map) {
    return SentenceModel(
      id: map['id'] as int,
      sentence: map['sentence'] as String,
    );
  }
}