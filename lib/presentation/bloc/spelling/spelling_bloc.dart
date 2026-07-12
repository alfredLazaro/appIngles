import 'package:bloc/bloc.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/presentation/bloc/spelling/spelling_event.dart';
import 'package:first_app/presentation/bloc/spelling/spelling_state.dart';

class SpellingBloc extends Bloc<SpellingEvent, SpellingState> {
  final ValidateWordAnswer _validateWordAnswer;
  final SpeakText _speakText;

  List<FlashcardWord> _words = [];
  final Map<int, int> _scores = {};
  int _currentIndex = 0;

  SpellingBloc({
    required ValidateWordAnswer validateWordAnswer,
    required SpeakText speakText,
  })  : _validateWordAnswer = validateWordAnswer,
        _speakText = speakText,
        super(const SpellingInitial()) {
    on<InitializeSpelling>(_onInitialize);
    on<PlayCurrentWordAudio>(_onPlayAudio);
    on<SubmitSpellingAnswer>(_onSubmitAnswer);
    on<NextSpellingWord>(_onNext);
    on<PreviousSpellingWord>(_onPrevious);
    on<SkipSpellingWord>(_onSkip);
    on<FinishSpelling>(_onFinish);
  }

  SpellingLoaded _buildLoaded(int index, {String userAnswer = '', bool? isCorrect, bool hasSubmitted = false}) {
    final word = _words[index];
    return SpellingLoaded(
      words: _words,
      currentIndex: index,
      currentWord: word,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      learnCount: _scores[word.id] ?? word.learnCount,
      scores: Map.from(_scores),
      maxAudioPlays: _maxAudioPlays,
      audioPlayedCount: 0,
      hasSubmitted: hasSubmitted,
    );
  }

  int _maxAudioPlays = 0;

  void _onInitialize(InitializeSpelling event, Emitter<SpellingState> emit) {
    _words = event.words;
    _currentIndex = 0;
    _scores.clear();
    _maxAudioPlays = event.maxAudioPlays;

    for (final word in _words) {
      _scores[word.id] = word.learnCount;
    }

    if (_words.isEmpty) {
      emit(const SpellingCompleted(
        learnCountUpdates: {},
        totalItems: 0,
        correctItems: 0,
      ));
      return;
    }

    emit(_buildLoaded(0));
  }

  Future<void> _onPlayAudio(
    PlayCurrentWordAudio event,
    Emitter<SpellingState> emit,
  ) async {
    final state = this.state;
    if (state is! SpellingLoaded) return;

    await _speakText(state.currentWord.word);
  }

  void _onSubmitAnswer(
    SubmitSpellingAnswer event,
    Emitter<SpellingState> emit,
  ) {
    final state = this.state;
    if (state is! SpellingLoaded || state.hasSubmitted) return;

    final isCorrect = _validateWordAnswer(event.answer, state.currentWord.word);
    final wordId = state.currentWord.id;

    if (isCorrect) {
      _scores[wordId] = (_scores[wordId] ?? 0) + 3;
    } else {
      _scores[wordId] = ((_scores[wordId] ?? 0) - 1).clamp(0, double.infinity).toInt();
    }

    emit(state.copyWith(
      userAnswer: event.answer,
      isCorrect: isCorrect,
      learnCount: _scores[wordId],
      scores: Map.from(_scores),
      hasSubmitted: true,
    ));
  }

  void _onNext(NextSpellingWord event, Emitter<SpellingState> emit) {
    final state = this.state;
    if (state is! SpellingLoaded) return;

    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _words.length) return;

    _currentIndex = nextIndex;
    emit(_buildLoaded(nextIndex));
  }

  void _onPrevious(PreviousSpellingWord event, Emitter<SpellingState> emit) {
    final state = this.state;
    if (state is! SpellingLoaded) return;

    final prevIndex = _currentIndex - 1;
    if (prevIndex < 0) return;

    _currentIndex = prevIndex;
    emit(_buildLoaded(prevIndex));
  }

  void _onSkip(SkipSpellingWord event, Emitter<SpellingState> emit) {
    final state = this.state;
    if (state is! SpellingLoaded) return;

    if (!state.hasSubmitted) {
      final wordId = state.currentWord.id;
      _scores[wordId] = ((_scores[wordId] ?? 0) - 1).clamp(0, double.infinity).toInt();
    }

    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _words.length) {
      _emitCompleted(emit);
      return;
    }

    _currentIndex = nextIndex;
    emit(_buildLoaded(nextIndex));
  }

  void _onFinish(FinishSpelling event, Emitter<SpellingState> emit) {
    _emitCompleted(emit);
  }

  void _emitCompleted(Emitter<SpellingState> emit) {
    final correctCount = _scores.values.where((s) => s > 0).length;
    emit(SpellingCompleted(
      learnCountUpdates: Map.from(_scores),
      totalItems: _words.length,
      correctItems: correctCount,
    ));
  }
}
