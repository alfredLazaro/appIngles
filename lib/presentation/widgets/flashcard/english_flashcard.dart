import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'flashcard_front.dart';
import 'flashcard_back.dart';

class EnglishFlashCard extends StatelessWidget {
  final Color textColor;
  final double borderRadius;
  final double? maxWidth;

  const EnglishFlashCard({
    super.key,
    this.textColor = AppColors.textPrimary,
    this.borderRadius = AppLayout.radiusLarge,
    this.maxWidth = 450.0,
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

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? double.infinity,
            ),
            child: GestureDetector(
              onTap: () {
                context.read<FlashcardBloc>().add(FlipFlashcard());
              },
              child: Container(
                margin: EdgeInsets.all(isPortrait ? 8.0 : 4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: FlashcardConstants.flipAnimationDuration,
                  ),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: state.showFront
                      ? FlashcardFront(
                          key: ValueKey(state.word.id),
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
            ),
          ),
        );
      },
    );
  }
}
