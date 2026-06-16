import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_event.dart';
import 'package:first_app/presentation/bloc/practice/practice_state.dart';
import 'package:first_app/presentation/pages/flashcard_practice_page.dart';
import 'package:first_app/presentation/pages/sentence_practice_page.dart';
import 'package:first_app/presentation/pages/matching_practice_page.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:first_app/presentation/widgets/modals/practice_selection_modal.dart';
import 'package:first_app/presentation/bloc/practice/practice_data.dart';

class PracticeConfigPage extends StatefulWidget {
  final PracticeType practiceType;

  const PracticeConfigPage({
    super.key,
    required this.practiceType,
  });

  @override
  State<PracticeConfigPage> createState() => _PracticeConfigPageState();
}

class _PracticeConfigPageState extends State<PracticeConfigPage> {
  bool _hasNavigated = false;
  bool _hasShownModal = false;
  bool _practiceStarted = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context
            .read<PracticeBloc>()
            .add(LoadPracticeDataEvent(widget.practiceType));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PracticeBloc, PracticeState>(
      listener: (context, state) {
        if (state is PracticeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context);
        }

        if (state is PracticeReady && !_hasNavigated) {
          _navigateToPractice(context, state);
        }

        if (state is PracticeCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Progreso guardado: ${state.result.correctItems} de ${state.result.totalItems} correctos',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is PracticeDataLoaded && !_hasShownModal) {
          _hasShownModal = true;
          _showPracticeModal(context, state.totalCount);
        }
      },
      builder: (context, state) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void _showPracticeModal(BuildContext context, int totalCount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PracticeSelectionModal(
        totalWords: totalCount,
        practiceType: widget.practiceType,
        onStartPractice: (count) {
          _practiceStarted = true;
          Navigator.pop(dialogContext);
          context.read<PracticeBloc>().add(
                StartPracticeEvent(count, widget.practiceType),
              );
        },
      ),
    ).then((_) {
      if (mounted && !_practiceStarted) {
        Navigator.pop(this.context);
      }
    });
  }

  void _navigateToPractice(BuildContext context, PracticeReady state) {
    _hasNavigated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => _buildPracticePage(state),
      ),
    );
  }

  Widget _buildPracticePage(PracticeReady state) {
    switch (widget.practiceType) {
      case PracticeType.flashcard:
        final flashcardData = state.practiceData as FlashcardPracticeData;
        return FlashcardPracticePage(
          words: flashcardData.words,
          imagesMap: flashcardData.imagesMap,
        );
      case PracticeType.sentence:
        final sentenceData = state.practiceData as SentencePracticeData;
        return SentencePracticePage(
          sentences: sentenceData.sentences,
        );
      case PracticeType.matching:
        final matchingData = state.practiceData as MatchingPracticeData;
        return MatchingPracticePage(
          data: matchingData,
        );
      case PracticeType.matchingDefinition:
        final defData = state.practiceData as MatchingDefPracticeData;
        return MatchingPracticePage(
          data: MatchingPracticeData(words: defData.words, rounds: defData.rounds),
          isDefinitionMode: true,
        );
      default:
        return const Scaffold(
          body: Center(child: Text('Práctica no disponible')),
        );
    }
  }
}
