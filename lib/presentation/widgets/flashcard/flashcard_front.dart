import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'flashcard_image.dart';
import 'flashcard_controls.dart';

class FlashcardFront extends StatelessWidget {
  final FlashcardWord word;
  final List<FlashcardImage> images;
  final Color textColor;

  const FlashcardFront({
    super.key,
    required this.word,
    required this.images,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
            maxWidth: constraints.maxWidth,
          ),
          padding: EdgeInsets.all(constraints.maxHeight * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlashcardImageWidget(
                images: images,
                height: constraints.maxHeight * 0.5,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    word.word.isNotEmpty ? word.word : 'Word not found',
                    style: TextStyle(
                      fontSize: constraints.maxHeight * 0.1,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                FlashcardConstants.tapToSeeDefinition,
                style: TextStyle(
                  fontSize: constraints.maxHeight * 0.02,
                  fontStyle: FontStyle.italic,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 10),
              FlashcardControls(
                height: constraints.maxHeight * 0.2,
                fontSize: constraints.maxHeight * 0.03,
                iconSize: constraints.maxHeight * 0.04,
                onLearned: () =>
                    context.read<FlashcardBloc>().add(IncrementLearnCount()),
                onReset: () =>
                    context.read<FlashcardBloc>().add(ResetLearnCount()),
              ),
            ],
          ),
        );
      },
    );
  }
}
