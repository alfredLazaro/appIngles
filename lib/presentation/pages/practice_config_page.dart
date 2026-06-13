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

class PracticeConfigPage extends StatelessWidget {
  final PracticeType practiceType;

  const PracticeConfigPage({
    super.key,
    required this.practiceType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PracticeBloc(
        wordRepository: sl(),
        imageRepository: sl(),
        translationRepository: sl(),
      )..add(LoadPracticeDataEvent(practiceType)),
      child: BlocConsumer<PracticeBloc, PracticeState>(
        listener: (context, state) {
          if (state is PracticeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          }

          if (state is PracticeReady) {
            _navigateToPractice(context, state);
          }
        },
        builder: (context, state) {
          if (state is PracticeLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is PracticeDataLoaded) {
            // Show modal automatically when data is loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showPracticeModal(context, state.totalCount);
            });
          }

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
        practiceType: practiceType,
        onStartPractice: (count) {
          Navigator.pop(dialogContext);
          context.read<PracticeBloc>().add(
                StartPracticeEvent(count, practiceType),
              );
        },
      ),
    ).then((_) {
      // If dialog is dismissed without starting, go back
      if (context.read<PracticeBloc>().state is! PracticeReady) {
        Navigator.pop(context);
      }
    });
  }

  void _navigateToPractice(BuildContext context, PracticeReady state) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (practiceType) {
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
        },
      ),
      (route) => route.isFirst,
    );
  }
}
