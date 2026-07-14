import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'flashcard_image.dart';
import 'flashcard_controls.dart';

class FlashcardBack extends StatelessWidget {
  final FlashcardWord word;
  final Color textColor;

  const FlashcardBack({
    super.key,
    required this.word,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FlashcardBloc>().state;
    if (state is! FlashcardLoaded) return const SizedBox.shrink();

    final images = state.images;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (images.isNotEmpty)
                SizedBox(
                  height: (constraints.maxHeight * 0.35).clamp(100.0, 200.0),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppLayout.radiusLarge),
                      topRight: Radius.circular(AppLayout.radiusLarge),
                    ),
                    child: FlashcardImageWidget(
                      images: images,
                      height: (constraints.maxHeight * 0.35).clamp(100.0, 200.0),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(
                  (constraints.maxHeight * 0.03).clamp(16.0, 32.0),
                ),
                child: Column(
                  children: [
                    Text(
                        word.word.isNotEmpty ? word.word : FlashcardConstants.wordNotFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (constraints.maxHeight * 0.08).clamp(28.0, 48.0),
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    if (word.definition.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.05,
                        ),
                        child: Text(
                          word.definition,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (constraints.maxHeight * 0.025).clamp(14.0, 18.0),
                            color: textColor.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    if (word.sentence.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.05,
                        ),
                        child: Text(
                          '"${word.sentence}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (constraints.maxHeight * 0.025).clamp(12.0, 16.0),
                            fontStyle: FontStyle.italic,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAudioButton(
                          context,
                          Icons.volume_up,
                          () => context
                              .read<FlashcardBloc>()
                              .add(SpeakFlashcardText(word.word)),
                          constraints,
                        ),
                        const SizedBox(width: 12),
                        if (word.sentence.isNotEmpty)
                          _buildAudioButton(
                            context,
                            Icons.format_quote,
                            () => context
                                .read<FlashcardBloc>()
                                .add(SpeakFlashcardText(word.sentence)),
                            constraints,
                          ),
                      ],
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    FlashcardControls(
                      height: (constraints.maxHeight * 0.18).clamp(40.0, 90.0),
                      fontSize: (constraints.maxHeight * 0.03).clamp(11.0, 16.0),
                      iconSize: (constraints.maxHeight * 0.04).clamp(16.0, 24.0),
                      onLearned: () {
                          context.read<FlashcardBloc>().add(IncrementLearnCount());
                          context.read<FlashcardBloc>().add(NextFlashcard());
                        },
                    ),
                    SizedBox(height: constraints.maxHeight * 0.01),
                    Text(
                      FlashcardConstants.tapToSeeWord,
                      style: TextStyle(
                        fontSize: (constraints.maxHeight * 0.02).clamp(10.0, 13.0),
                        fontStyle: FontStyle.italic,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAudioButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    BoxConstraints constraints,
  ) {
    return Container(
      decoration: BoxDecoration(
                      color: FlashcardConstants.audioBtnBg.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: (constraints.maxHeight * 0.045).clamp(20.0, 28.0),
                          color: AppColors.textAccent,
        ),
        onPressed: onPressed,
        tooltip: 'Escuchar',
      ),
    );
  }
}
