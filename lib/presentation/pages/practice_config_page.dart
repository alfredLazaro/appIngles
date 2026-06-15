import 'package:first_app/core/di/dependency_injection.dart';
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
  late final PracticeBloc _practiceBloc;
  bool _hasNavigated = false;
  bool _hasShownModal = false;
  bool _practiceStarted = false;
  @override
  void initState() {
    super.initState();
    _practiceBloc = PracticeBloc(
      wordRepository: sl(),
      imageRepository: sl(),
      translationRepository: sl(),
    )..add(LoadPracticeDataEvent(widget.practiceType));
  }

  @override
  void dispose() {
    _practiceBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _practiceBloc,
      child: BlocConsumer<PracticeBloc, PracticeState>(
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
      ),
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
          _practiceStarted = false;
          Navigator.pop(dialogContext);
          context.read<PracticeBloc>().add(
                StartPracticeEvent(count, widget.practiceType),
              );
        },
      ),
    ).then((_) {
      // If dialog is dismissed without starting, go back
      if (!_practiceStarted) {
        Navigator.pop(context);
      }
    });
  }

  void _navigateToPractice(BuildContext context, PracticeReady state) {
    _hasNavigated = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: _practiceBloc,
          child: _buildPracticePage(state),
        ),
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
      default:
        return const Scaffold(
          body: Center(child: Text('Práctica no disponible')),
        );
    }
  }
}
