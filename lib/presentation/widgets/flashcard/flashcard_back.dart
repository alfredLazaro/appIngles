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
        return Container(
          constraints: BoxConstraints(
            minHeight: constraints.minHeight,
            maxWidth: constraints.maxWidth,
          ),
          padding: EdgeInsets.all((constraints.maxHeight * 0.02).clamp(6.0, 14.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlashcardImageWidget(
                    images: images,
                    height: (constraints.maxHeight * 0.35).clamp(100.0, 200.0),
                  ),
                ),
              SizedBox(height: constraints.maxHeight * 0.02),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    word.word.isNotEmpty ? word.word : 'Word not found',
                    style: TextStyle(
                      fontSize: (constraints.maxHeight * 0.1).clamp(28.0, 48.0),
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.01),
              if (word.sentence.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.05,
                  ),
                  child: Text(
                    '"${word.sentence}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (constraints.maxHeight * 0.03).clamp(11.0, 16.0),
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ),
              SizedBox(height: constraints.maxHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.volume_up,
                        size: (constraints.maxHeight * 0.05).clamp(20.0, 28.0)),
                    onPressed: () => context
                        .read<FlashcardBloc>()
                        .add(SpeakFlashcardText(word.word)),
                    tooltip: 'Escuchar palabra',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.format_quote,
                        size: (constraints.maxHeight * 0.05).clamp(20.0, 28.0)),
                    onPressed: () => context
                        .read<FlashcardBloc>()
                        .add(SpeakFlashcardText(word.sentence)),
                    tooltip: 'Escuchar oración',
                  ),
                ],
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              FlashcardControls(
                height: (constraints.maxHeight * 0.18).clamp(40.0, 90.0),
                fontSize: (constraints.maxHeight * 0.03).clamp(11.0, 16.0),
                iconSize: (constraints.maxHeight * 0.04).clamp(16.0, 24.0),
                onLearned: () =>
                    context.read<FlashcardBloc>().add(IncrementLearnCount()),
                onReset: () =>
                    context.read<FlashcardBloc>().add(ResetLearnCount()),
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
        );
      },
    );
  }
}
