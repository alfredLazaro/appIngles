import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final ValidateWordAnswer _validateWordAnswer;
  final SpeakText _speakText;

  List<FlashcardSession> _sessions = [];
  int _currentIndex = 0;
  final Map<int, int> _scores = {};
  Map<int, List<FlashcardImage>> _imagesMap = {};

  FlashcardBloc({
    required ValidateWordAnswer validateWordAnswer,
    required SpeakText speakText,
  })  : _validateWordAnswer = validateWordAnswer,
        _speakText = speakText,
        super(const FlashcardInitial()) {
    on<InitializeSession>(_onInitializeSession);
    on<NextFlashcard>(_onNextFlashcard);
    on<PreviousFlashcard>(_onPreviousFlashcard);
    on<FlipFlashcard>(_onFlipFlashcard);
    on<IncrementLearnCount>(_onIncrementLearnCount);
    on<DecrementLearnCount>(_onDecrementLearnCount);
    on<ResetLearnCount>(_onResetLearnCount);
    on<ValidateAnswer>(_onValidateAnswer);
    on<SpeakFlashcardText>(_onSpeakText);
    on<MarkAsKnown>(_onMarkAsKnown);
    on<MarkAsUnknown>(_onMarkAsUnknown);
    on<RevealAnswer>(_onRevealAnswer);
  }

  List<FlashcardSession> _generateSessions(
      List<FlashcardWord> words, int batchSize) {
    final sessions = <FlashcardSession>[];

    for (int i = 0; i < words.length; i += batchSize) {
      final end = (i + batchSize < words.length) ? i + batchSize : words.length;
      final batch = words.sublist(i, end);

      for (int j = 0; j < batch.length; j++) {
        if (batch[j].learnCount <= 50) {
          sessions.add(FlashcardSession(
            word: batch[j],
            mode: FlashcardMode.learn,
            originalIndex: i + j,
          ));
        }
      }

      for (int j = 0; j < batch.length; j++) {
        sessions.add(FlashcardSession(
          word: batch[j],
          mode: FlashcardMode.test,
          originalIndex: i + j,
        ));
      }
    }

    return sessions;
  }

  FlashcardLoaded _buildLoadedState(int index) {
    final session = _sessions[index];
    final images = _imagesMap[session.word.id] ?? [];

    return FlashcardLoaded(
      sessions: _sessions,
      currentIndex: index,
      word: session.word,
      images: images,
      mode: session.mode,
      originalIndex: session.originalIndex,
      showFront: true,
      learnCount: _scores[session.word.id] ?? session.word.learnCount,
      scores: Map.from(_scores),
      isAnswerCorrect: null,
      isAnswerRevealed: false,
      userAnswer: '',
    );
  }

  void _onInitializeSession(
      InitializeSession event, Emitter<FlashcardState> emit) {
    _sessions = _generateSessions(event.words, event.batchSize);
    _currentIndex = 0;
    _scores.clear();
    _imagesMap = event.imagesMap;

    for (final word in event.words) {
      _scores[word.id] = word.learnCount;
    }

    emit(_buildLoadedState(0));
  }

  void _onNextFlashcard(NextFlashcard event, Emitter<FlashcardState> emit) {
    if (state is! FlashcardLoaded) return;

    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _sessions.length) {
      emit(FlashcardCompleted(scores: Map.from(_scores)));
      return;
    }

    _currentIndex = nextIndex;
    emit(_buildLoadedState(nextIndex));
  }

  void _onPreviousFlashcard(
      PreviousFlashcard event, Emitter<FlashcardState> emit) {
    if (state is! FlashcardLoaded) return;

    final prevIndex = _currentIndex - 1;
    if (prevIndex < 0) return;

    _currentIndex = prevIndex;
    emit(_buildLoadedState(prevIndex));
  }

  void _onFlipFlashcard(FlipFlashcard event, Emitter<FlashcardState> emit) {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      emit(currentState.copyWith(showFront: !currentState.showFront));
    }
  }

  void _onIncrementLearnCount(
      IncrementLearnCount event, Emitter<FlashcardState> emit) {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final increment = event.amount ?? 1;
      final newCount = currentState.learnCount + increment;

      _scores[currentState.word.id] = newCount;
      emit(currentState.copyWith(
          learnCount: newCount, scores: Map.from(_scores)));
    }
  }

  void _onDecrementLearnCount(
      DecrementLearnCount event, Emitter<FlashcardState> emit) {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final decrement = event.amount ?? 1;
      final newCount = (currentState.learnCount - decrement)
          .clamp(0, double.infinity)
          .toInt();

      _scores[currentState.word.id] = newCount;
      emit(currentState.copyWith(
          learnCount: newCount, scores: Map.from(_scores)));
    }
  }

  void _onResetLearnCount(ResetLearnCount event, Emitter<FlashcardState> emit) {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;

      _scores[currentState.word.id] = 0;
      emit(currentState.copyWith(learnCount: 0, scores: Map.from(_scores)));
    }
  }

  Future<void> _onValidateAnswer(
      ValidateAnswer event, Emitter<FlashcardState> emit) async {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final isCorrect =
          _validateWordAnswer(event.userAnswer, currentState.word.word);

      if (isCorrect) {
        final newCount = currentState.learnCount + 3;
        _scores[currentState.word.id] = newCount;
        emit(currentState.copyWith(
            learnCount: newCount,
            isAnswerCorrect: true,
            userAnswer: event.userAnswer,
            scores: Map.from(_scores)));
        await Future.delayed(const Duration(seconds: 1));
        emit(currentState.copyWith(
            learnCount: newCount,
            isAnswerCorrect: true,
            showFront: false,
            userAnswer: event.userAnswer,
            scores: Map.from(_scores)));
      } else {
        final newCount =
            (currentState.learnCount - 1).clamp(0, double.infinity).toInt();
        _scores[currentState.word.id] = newCount;
        emit(currentState.copyWith(
            learnCount: newCount,
            isAnswerCorrect: false,
            userAnswer: event.userAnswer,
            scores: Map.from(_scores)));
        await Future.delayed(const Duration(seconds: 1));
        emit(currentState.copyWith(
            learnCount: newCount,
            isAnswerCorrect: false,
            showFront: false,
            userAnswer: event.userAnswer,
            scores: Map.from(_scores)));
      }
    }
  }

  Future<void> _onSpeakText(
      SpeakFlashcardText event, Emitter<FlashcardState> emit) async {
    await _speakText(event.text);
  }

  void _onMarkAsKnown(MarkAsKnown event, Emitter<FlashcardState> emit) {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final masteryLevel = event.masteryLevel ?? 5;

      _scores[currentState.word.id] = masteryLevel;
      emit(currentState.copyWith(
          learnCount: masteryLevel, scores: Map.from(_scores)));
    }
  }

  void _onMarkAsUnknown(MarkAsUnknown event, Emitter<FlashcardState> emit) {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;

      _scores[currentState.word.id] = 0;
      emit(currentState.copyWith(learnCount: 0, scores: Map.from(_scores)));
    }
  }

  void _onRevealAnswer(RevealAnswer event, Emitter<FlashcardState> emit) {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final wordId = currentState.word.id;
      final newCount =
          (currentState.learnCount - 1).clamp(0, double.infinity).toInt();
      _scores[wordId] = newCount;
      emit(currentState.copyWith(
          learnCount: newCount,
          isAnswerRevealed: true,
          scores: Map.from(_scores)));
    }
  }
}
