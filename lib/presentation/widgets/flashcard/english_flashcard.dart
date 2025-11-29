import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'flashcard_front.dart';
import 'flashcard_back.dart';

/// Widget principal de la flashcard (ahora solo maneja UI)
class EnglishFlashCard extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final double borderRadius;

  const EnglishFlashCard({
    super.key,
    this.cardColor = Colors.white,
    this.textColor = Colors.black,
    this.borderRadius = FlashcardConstants.defaultBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;

    return BlocBuilder<FlashcardBloc, FlashcardState>(
      builder: (context, state) {
        if (state is! FlashcardLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return GestureDetector(
          onTap: () => context.read<FlashcardBloc>().add(FlipFlashcard()),
          child: Card(
            elevation: 5.0,
            margin: EdgeInsets.all(isPortrait ? 8.0 : 4.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            color: cardColor,
            child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: FlashcardConstants.flipAnimationDuration,
              ),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: state.showFront
                  ? FlashcardFront(
                      key: const ValueKey('front'),
                      word: state.word,
                      images: state.images,
                      textColor: textColor,
                    )
                  : FlashcardBack(
                      key: const ValueKey('back'),
                      word: state.word,
                      textColor: textColor,
                    ),
            ),
          ),
        );
      },
    );
  }
}
