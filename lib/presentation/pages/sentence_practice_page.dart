import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/domain/entities/sentence_model.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';
import 'package:first_app/presentation/bloc/practice/practice_event.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:first_app/presentation/widgets/controlers/page_navegation_controls.dart';
import 'package:first_app/presentation/widgets/dialogs/completion_dialog.dart';
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
  final PageController _pageController = PageController();
  int get totalSentences => widget.sentences.length;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    //_loadSentences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordenar Oraciones (${_currentIndex + 1}/$totalSentences)'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${((_currentIndex + 1) / totalSentences * 100).toInt()}%',
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
                  value: (_currentIndex + 1) / totalSentences,
                  minHeight: 6,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalSentences,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final sentence = widget.sentences[index];
                      return SentenceBuilderWidget(
                        key: ValueKey(sentence.id),
                        sentenceId: sentence.id,
                        originalSentence: sentence.sentence,
                        ttsService: _ttsService,
                      );
                    },
                  ),
                ),
                PageNavigationControls(
                  currentIndex: _currentIndex,
                  totalPages: widget.sentences.length,
                  onPrevious: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  onNext: _currentIndex < widget.sentences.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : () => _showCompletionDialog(),
                ),
              ],
            ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CompletionDialog(
          totalItems: widget.sentences.length,
          learnedCount: widget.sentences.length,
          itemName: 'sentence',
          onFinish: () {
            final learnCountUpdates = <int, int>{
              for (final s in widget.sentences)
                s.id: s.learnCount + 1,
            };
            context.read<PracticeBloc>().add(
                  FinishPracticeEvent(PracticeResult(
                    type: PracticeType.sentence,
                    learnCountUpdates: learnCountUpdates,
                    totalItems: widget.sentences.length,
                    correctItems: widget.sentences.length,
                  )),
                );
            Navigator.pop(dialogContext);
            Navigator.pop(context);
          },
          onRepeat: () {
            Navigator.pop(dialogContext);
            setState(() {
              _currentIndex = 0;
              _pageController.jumpToPage(0);
            });
          }),
    );
  }
}
