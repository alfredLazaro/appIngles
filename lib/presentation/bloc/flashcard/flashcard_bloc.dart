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
    on<DecrementLearnCount>(_onDecrementLearnCount);
    on<ResetLearnCount>(_onResetLearnCount);
    on<ValidateAnswer>(_onValidateAnswer);
    on<SpeakFlashcardText>(_onSpeakText);
    on<MarkAsKnown>(_onMarkAsKnown);
    on<MarkAsUnknown>(_onMarkAsUnknown);
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
      final increment = event.amount ?? 1;
      final newCount = currentState.learnCount + increment;
      
      emit(currentState.copyWith(learnCount: newCount));
      
      await _wordRepository.updateLearnCount(
        currentState.word.id,
        newCount,
      );
    }
  }

  void _onDecrementLearnCount(
      DecrementLearnCount event, Emitter<FlashcardState> emit) async {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final decrement = event.amount ?? 1;
      // Ensure learnCount doesn't go below 0
      final newCount = (currentState.learnCount - decrement).clamp(0, double.infinity).toInt();
      
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

  void _onValidateAnswer(ValidateAnswer event, Emitter<FlashcardState> emit) async {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final isCorrect =
          _validateWordAnswer(event.userAnswer, currentState.word.word);
      
      // Emit validation state
      emit(FlashcardAnswerValidated(isCorrect));
      
      // Update learn count based on correctness
      if (isCorrect) {
        final newCount = currentState.learnCount + 2; // Increment by 2 for correct answer
        final updatedState = currentState.copyWith(learnCount: newCount);
        emit(updatedState);
        
        await _wordRepository.updateLearnCount(
          currentState.word.id,
          newCount,
        );
      } else {
        // Optionally decrement on wrong answer (configurable behavior)
        final newCount = (currentState.learnCount - 1).clamp(0, double.infinity).toInt();
        final updatedState = currentState.copyWith(learnCount: newCount);
        emit(updatedState);
        
        await _wordRepository.updateLearnCount(
          currentState.word.id,
          newCount,
        );
      }
    }
  }

  Future<void> _onSpeakText(
      SpeakFlashcardText event, Emitter<FlashcardState> emit) async {
    await _speakText(event.text);
  }

  // Mark word as fully known (e.g., set to mastery level)
  void _onMarkAsKnown(MarkAsKnown event, Emitter<FlashcardState> emit) async {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      final masteryLevel = event.masteryLevel ?? 5; // Default mastery level
      
      emit(currentState.copyWith(learnCount: masteryLevel));
      
      await _wordRepository.updateLearnCount(
        currentState.word.id,
        masteryLevel,
      );
    }
  }

  // Mark word as unknown (reset to 0)
  void _onMarkAsUnknown(MarkAsUnknown event, Emitter<FlashcardState> emit) async {
    if (state is FlashcardLoaded) {
      final currentState = state as FlashcardLoaded;
      
      emit(currentState.copyWith(learnCount: 0));
      
      await _wordRepository.updateLearnCount(
        currentState.word.id,
        0,
      );
    }
  }
}