import 'package:first_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_event.dart';
import 'package:first_app/presentation/bloc/practice/practice_state.dart';
import 'package:first_app/presentation/pages/flashcard_practice_page.dart';
import 'package:first_app/presentation/pages/sentence_practice_page.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';
import 'package:first_app/presentation/widgets/modals/practice_selection_modal.dart';

class PracticeConfigPage extends StatelessWidget {
  final PracticeType practiceType;

  const PracticeConfigPage({
    super.key,
    required this.practiceType,
  });

  @override
  Widget build(BuildContext context) {
    final dep = Dependencies.instance;
    return BlocProvider(
      create: (context) => PracticeBloc(
        wordRepository: dep.wordRepository,
        imageRepository: dep.imageRepository,
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
          // Use the outer context (BlocProvider context)
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
    // Close the config page first
    Navigator.pop(context);

    // Then navigate to practice
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          switch (practiceType) {
            case PracticeType.flashcard:
              return FlashcardPracticePage(
                words: state.words,
                imagesMap: state.imagesMap,
              );
            case PracticeType.sentence:
              return SentencePracticePage(
                sentenceCount: state.words.length,
              );
            default:
              return const Scaffold(
                body: Center(child: Text('Práctica no disponible')),
              );
          }
        },
      ),
    );
  }
}
