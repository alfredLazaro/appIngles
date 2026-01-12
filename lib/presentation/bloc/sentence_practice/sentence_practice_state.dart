// lib/presentation/bloc/sentence_practice/sentence_practice_state.dart

abstract class SentencePracticeState {}

class SentencePracticeInitial extends SentencePracticeState {}

class SentencePracticeLoading extends SentencePracticeState {}

class SentencePracticeLoaded extends SentencePracticeState {
  final List<SentenceData> sentences;
  final int currentIndex;
  final Map<int, bool> answersCorrect; // sentenceId → isCorrect
  final Map<int, bool> answersChecked; // sentenceId → hasBeenChecked

  SentencePracticeLoaded({
    required this.sentences,
    this.currentIndex = 0,
    Map<int, bool>? answersCorrect,
    Map<int, bool>? answersChecked,
  })  : answersCorrect = answersCorrect ?? {},
        answersChecked = answersChecked ?? {};

  SentencePracticeLoaded copyWith({
    List<SentenceData>? sentences,
    int? currentIndex,
    Map<int, bool>? answersCorrect,
    Map<int, bool>? answersChecked,
  }) {
    return SentencePracticeLoaded(
      sentences: sentences ?? this.sentences,
      currentIndex: currentIndex ?? this.currentIndex,
      answersCorrect: answersCorrect ?? this.answersCorrect,
      answersChecked: answersChecked ?? this.answersChecked,
    );
  }

  SentenceData get currentSentence => sentences[currentIndex];
  bool get hasNext => currentIndex < sentences.length - 1;
  bool get hasPrevious => currentIndex > 0;
  int get completedCount => answersCorrect.values.where((v) => v).length;
  double get progress => (currentIndex + 1) / sentences.length;
}

class SentenceAnswerValidated extends SentencePracticeState {
  final bool isCorrect;
  final String correctAnswer;
  
  SentenceAnswerValidated({
    required this.isCorrect,
    required this.correctAnswer,
  });
}

class SentencePracticeError extends SentencePracticeState {
  final String message;
  SentencePracticeError(this.message);
}

// Data class for sentence information
class SentenceData {
  final int id;
  final String sentence;
  final List<String> words;
  final List<String> shuffledWords;

  SentenceData({
    required this.id,
    required this.sentence,
    required this.words,
    required this.shuffledWords,
  });

  factory SentenceData.fromMap(Map<String, dynamic> map) {
    final sentence = map['sentence'] as String;
    final words = sentence.split(' ');
    final shuffledWords = List<String>.from(words)..shuffle();

    return SentenceData(
      id: map['id'] as int,
      sentence: sentence,
      words: words,
      shuffledWords: shuffledWords,
    );
  }
}