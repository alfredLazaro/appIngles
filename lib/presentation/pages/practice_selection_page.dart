import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/presentation/bloc/practice/practice_bloc.dart';
import 'package:first_app/presentation/widgets/modals/practice_selection_modal.dart';

enum PracticeType { flashcard, sentence }

class PracticeSelectionPage extends StatelessWidget {
  final PracticeType practiceType;

  const PracticeSelectionPage({
    super.key,
    required this.practiceType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PracticeBloc(
        wordRepository: context.read(),
        imageRepository: context.read(),
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
            return Scaffold(
              body: Center(
                child: PracticeSelectionModal(
                  totalWords: state.totalCount,
                  title: practiceType == PracticeType.flashcard
                      ? 'Modo Práctica'
                      : 'Ordenar Oraciones',
                  description: practiceType == PracticeType.flashcard
                      ? '¿Cuántas palabras quieres practicar?'
                      : '¿Cuántas oraciones quieres ordenar?',
                  onStartPractice: (count) {
                    context.read<PracticeBloc>().add(
                          StartPracticeEvent(count, practiceType),
                        );
                  },
                ),
              ),
            );
          }

          return const Scaffold(
            body: Center(child: Text('Preparando práctica...')),
          );
        },
      ),
    );
  }

  void _navigateToPractice(BuildContext context, PracticeReady state) {
    final route = practiceType == PracticeType.flashcard
        ? '/flashcard-practice'
        : '/sentence-practice';

    Navigator.pushReplacementNamed(
      context,
      route,
      arguments: state.practiceData,
    );
  }
}