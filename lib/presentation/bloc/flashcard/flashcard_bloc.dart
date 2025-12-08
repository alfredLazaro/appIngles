import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final ValidateWordAnswer _validateWordAnswer;
  final SpeakText _speakText;
  final WordRepository _wordRepository;
  FlashcardBloc({
    required ValidateWordAnswer validateWordAnswer,
    required SpeakText speakText,
    required WordRepository wordRepository,
    FlashcardState? initialState,
  })  : _validateWordAnswer = validateWordAnswer,
        _speakText = speakText,
        _wordRepository = wordRepository,
        super(initialState ?? FlashcardInitial()) {
    on<FlipFlashcard>(_onFlipFlashcard);
    on<IncrementLearnCount>(_onIncrementLearnCount);
    on<ResetLearnCount>(_onResetLearnCount);
    on<ValidateAnswer>(_onValidateAnswer);
    on<SpeakFlashcardText>(_onSpeakText);
  }

  void _onFlipFlashcard(FlipFlashcard event, Emitter<FlashcardState> emit) {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      emit(currentState.copyWith(showFront: !currentState.showFront));
    }
  }

  void _onIncrementLearnCount(
      IncrementLearnCount event, Emitter<FlashcardState> emit) async {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final newCount = currentState.learnCount + 1;
      emit(currentState.copyWith(learnCount: newCount));
      await _wordRepository.updateLearnCount(
        currentState.word.id,
        newCount,
      );
    }
  }

  void _onResetLearnCount(
      ResetLearnCount event, Emitter<FlashcardState> emit) async {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      emit(currentState.copyWith(learnCount: 0));
      await _wordRepository.updateLearnCount(
        currentState.word.id,
        0,
      );
    }
  }

  void _onValidateAnswer(ValidateAnswer event, Emitter<FlashcardState> emit) {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final isCorrect =
          _validateWordAnswer(event.userAnswer, currentState.word.word);
      emit(FlashcardAnswerValidated(isCorrect));
      // Volver al estado cargado
      emit(currentState);
    }
  }

  Future<void> _onSpeakText(
      SpeakFlashcardText event, Emitter<FlashcardState> emit) async {
    await _speakText(event.text);
  }
}
