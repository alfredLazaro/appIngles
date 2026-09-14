import 'package:first_app/domain/entities/sentence_model.dart';
import 'package:first_app/presentation/bloc/sentence_practice/sentence_practice_bloc.dart';
import 'package:first_app/presentation/bloc/sentence_practice/sentence_practice_event.dart';
import 'package:first_app/presentation/bloc/sentence_practice/sentence_practice_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _sentences = [
  SentenceModel(id: 1, sentence: 'I am learning english', learnCount: 10),
  SentenceModel(id: 2, sentence: 'This is a test', learnCount: 0),
];

void main() {
  Future<void> pump(SentencePracticeBloc bloc) async {
    // Let a queued event finish before asserting on the emitted state.
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  Future<void> initialize(SentencePracticeBloc bloc) async {
    bloc.add(const InitializeSentencesEvent(sentences: _sentences));
    await pump(bloc);
  }

  Future<void> buildSentenceInOrder(SentencePracticeBloc bloc) async {
    final state = bloc.state as SentencePracticeLoaded;
    final tokens = state.originalSentence.trim().split(RegExp(r'\s+'));
    for (final token in tokens) {
      final index = state.shuffledWords.indexOf(token);
      bloc.add(AddWordToSentenceEvent(word: token, wordIndex: index));
      await pump(bloc);
    }
  }

  test('awarded +4 for a correct answer', () async {
    final bloc = SentencePracticeBloc();
    await initialize(bloc);

    await buildSentenceInOrder(bloc);
    bloc.add(const CheckAnswerEvent());
    await pump(bloc);

    final state = bloc.state as SentencePracticeLoaded;
    expect(state.isCorrect, isTrue);
    expect(state.learnCount, 14);

    await bloc.close();
  });

  test('subtracts 1 for an incorrect answer', () async {
    final bloc = SentencePracticeBloc();
    await initialize(bloc);

    // Build the sentence in reverse order to force an incorrect answer.
    final state = bloc.state as SentencePracticeLoaded;
    final tokens = state.originalSentence.trim().split(RegExp(r'\s+'));
    final reversed = tokens.reversed.toList();
    for (final token in reversed) {
      final index = state.shuffledWords.indexOf(token);
      bloc.add(AddWordToSentenceEvent(word: token, wordIndex: index));
      await pump(bloc);
    }
    bloc.add(const CheckAnswerEvent());
    await pump(bloc);

    final wrongState = bloc.state as SentencePracticeLoaded;
    expect(wrongState.isCorrect, isFalse);
    expect(wrongState.learnCount, 9);

    await bloc.close();
  });

  test('clamps the learn count at 0 when answering incorrectly', () async {
    final bloc = SentencePracticeBloc();
    await initialize(bloc);

    // Move to the second sentence, which starts at learnCount 0.
    bloc.add(const NextSentenceEvent());
    await pump(bloc);

    final state = bloc.state as SentencePracticeLoaded;
    expect(state.sentenceId, 2);
    expect(state.learnCount, 0);

    final tokens = state.originalSentence.trim().split(RegExp(r'\s+'));
    final reversed = tokens.reversed.toList();

    void answerWrong() {
      for (final token in reversed) {
        final index = state.shuffledWords.indexOf(token);
        bloc.add(AddWordToSentenceEvent(word: token, wordIndex: index));
      }
    }

    answerWrong();
    await pump(bloc);
    bloc.add(const CheckAnswerEvent());
    await pump(bloc);

    expect((bloc.state as SentencePracticeLoaded).learnCount, 0);

    bloc.add(const ResetSentenceEvent());
    await pump(bloc);
    answerWrong();
    await pump(bloc);
    bloc.add(const CheckAnswerEvent());
    await pump(bloc);

    expect((bloc.state as SentencePracticeLoaded).learnCount, 0);

    await bloc.close();
  });

  test('accumulates deltas across retries of the same sentence', () async {
    final bloc = SentencePracticeBloc();
    await initialize(bloc);

    await buildSentenceInOrder(bloc);
    bloc.add(const CheckAnswerEvent());
    await pump(bloc);

    final first = bloc.state as SentencePracticeLoaded;
    expect(first.learnCount, 14);

    // Reset and answer correctly again -> +4 accumulates on top.
    bloc.add(const ResetSentenceEvent());
    await pump(bloc);
    await buildSentenceInOrder(bloc);
    bloc.add(const CheckAnswerEvent());
    await pump(bloc);

    final second = bloc.state as SentencePracticeLoaded;
    expect(second.learnCount, 18);

    await bloc.close();
  });

  test('emits Completed with learnCountUpdates, totalItems and correctItems',
      () async {
    final bloc = SentencePracticeBloc();
    await initialize(bloc);

    await buildSentenceInOrder(bloc);
    bloc.add(const CheckAnswerEvent());
    await pump(bloc);

    bloc.add(const FinishSentenceEvent());
    await pump(bloc);

    final completed = bloc.state as SentencePracticeCompleted;
    expect(completed.totalItems, _sentences.length);
    expect(completed.correctItems, 1);
    expect(completed.learnCountUpdates[1], 14);
    expect(completed.learnCountUpdates[2], 0);

    await bloc.close();
  });
}