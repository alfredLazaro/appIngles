import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/sentence_model.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/bloc/practice/practice_event.dart';
import 'package:first_app/presentation/bloc/sentence_practice/sentence_practice_bloc.dart';
import 'package:first_app/presentation/bloc/sentence_practice/sentence_practice_event.dart';
import 'package:first_app/presentation/bloc/sentence_practice/sentence_practice_state.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:first_app/presentation/widgets/controlers/page_navegation_controls.dart';
import 'package:first_app/presentation/widgets/practice_results_widget.dart';
import 'package:first_app/presentation/widgets/sentence/sentence_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/services/tts_service_interface.dart';

class SentencePracticePage extends StatefulWidget {
  final List<SentenceModel> sentences;
  const SentencePracticePage({
    super.key,
    required this.sentences,
  });

  @override
  State<SentencePracticePage> createState() => _SentencePracticePageState();
}

class _SentencePracticePageState extends State<SentencePracticePage> {
  final ITtsService _ttsService = sl<ITtsService>();
  late final SentencePracticeBloc _bloc;
  bool _resultSubmitted = false;

  int get totalSentences => widget.sentences.length;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    _bloc = SentencePracticeBloc()
      ..add(InitializeSentencesEvent(sentences: widget.sentences));
  }

  @override
  void dispose() {
    _bloc.close();
    _ttsService.stop();
    super.dispose();
  }

  void _submitResult(SentencePracticeCompleted state) {
    if (_resultSubmitted) return;
    _resultSubmitted = true;

    final result = PracticeResult(
      type: PracticeType.sentence,
      learnCountUpdates: state.learnCountUpdates,
      totalItems: state.totalItems,
      correctItems: state.correctItems,
    );
    context.read<PracticeBloc>().add(FinishPracticeEvent(result));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SentencePracticeBloc>.value(
      value: _bloc,
      child: BlocConsumer<SentencePracticeBloc, SentencePracticeState>(
        listener: (context, state) {
          if (state is SentencePracticeCompleted) {
            _submitResult(state);
          } else if (state is SentencePracticeLoaded) {
            _ttsService.speak(state.originalSentence);
          }
        },
        builder: (context, state) {
          if (state is SentencePracticeCompleted) {
            return PracticeResultsWidget(
              practiceType: PracticeType.sentence,
              totalItems: state.totalItems,
              correctItems: state.correctItems,
              words: _sentencesAsWords(),
              learnCountUpdates: state.learnCountUpdates,
              onFinish: () => Navigator.pop(context),
            );
          }

          if (state is! SentencePracticeLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return _buildPractice(context, state);
        },
      ),
    );
  }

  Widget _buildPractice(
    BuildContext context,
    SentencePracticeLoaded state,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordenar Oraciones (${state.currentIndex + 1}/$totalSentences)'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${((state.currentIndex + 1) / totalSentences * 100).toInt()}%',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: totalSentences == 0
          ? const Center(child: Text('No hay oraciones disponibles'))
          : Column(
              children: [
                LinearProgressIndicator(
                  value: (state.currentIndex + 1) / totalSentences,
                  minHeight: 6,
                ),
                Expanded(
                  child: SentenceBuilderWidget(
                    key: ValueKey(state.sentenceId),
                    ttsService: _ttsService,
                  ),
                ),
                PageNavigationControls(
                  currentIndex: state.currentIndex,
                  totalPages: totalSentences,
                  onPrevious: () {
                    _bloc.add(const PreviousSentenceEvent());
                  },
                  onNext: state.currentIndex < totalSentences - 1
                      ? () => _bloc.add(const NextSentenceEvent())
                      : () => _bloc.add(const FinishSentenceEvent()),
                ),
              ],
            ),
    );
  }

  List<FlashcardWord> _sentencesAsWords() {
    return widget.sentences
        .map((s) => FlashcardWord(
              id: s.id,
              word: s.sentence,
              sentence: '',
              definition: '',
              learnCount: s.learnCount,
            ))
        .toList();
  }
}