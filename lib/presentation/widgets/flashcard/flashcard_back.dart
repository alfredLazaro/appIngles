import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'word_test_input.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(constraints.maxHeight * 0.02),
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
            maxWidth: constraints.maxWidth,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(constraints.maxHeight * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WordTestInput(
                    onSubmit: (answer) => context
                        .read<FlashcardBloc>()
                        .add(ValidateAnswer(answer)),
                    constraints: constraints,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  _buildDefinitionSection(context, constraints),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  _buildExampleSection(context, constraints),
                  SizedBox(height: constraints.maxHeight * 0.04),
                  Text(
                    FlashcardConstants.tapToSeeWord,
                    style: TextStyle(
                      fontSize: constraints.maxHeight * 0.022,
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefinitionSection(
      BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              FlashcardConstants.definitionLabel,
              style: TextStyle(
                fontSize: constraints.maxHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.volume_up, size: constraints.maxHeight * 0.05),
              onPressed: () => context
                  .read<FlashcardBloc>()
                  .add(SpeakFlashcardText(word.definition)),
            ),
          ],
        ),
        SizedBox(height: constraints.maxHeight * 0.003),
        Text(
          word.definition,
          style: TextStyle(
            fontSize: constraints.maxHeight * 0.03,
            color: textColor,
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildExampleSection(
      BuildContext context, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              FlashcardConstants.exampleLabel,
              style: TextStyle(
                fontSize: constraints.maxHeight * 0.03,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.volume_up, size: constraints.maxHeight * 0.05),
              onPressed: () => context
                  .read<FlashcardBloc>()
                  .add(SpeakFlashcardText(word.sentence)),
            ),
          ],
        ),
        SizedBox(height: constraints.maxHeight * 0.003),
        Text(
          '"${word.sentence}"',
          style: TextStyle(
            fontSize: constraints.maxHeight * 0.03,
            fontStyle: FontStyle.italic,
            color: textColor,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}
