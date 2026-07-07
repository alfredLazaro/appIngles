import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/widgets/flashcard/flashcard_image.dart';

class WordFlashcard extends StatelessWidget {
  final FlashcardWord word;
  final List<FlashcardImage> images;
  final Color backgroundColor;
  final Color textColor;

  const WordFlashcard({
    super.key,
    required this.word,
    required this.images,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF191C1E),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFC6C5D3).withOpacity(0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (images.isNotEmpty)
                FlashcardImageWidget(
                  images: images,
                  height: (constraints.maxHeight * 0.35).clamp(120.0, 220.0),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: (constraints.maxHeight * 0.02).clamp(10.0, 16.0),
                    horizontal: (constraints.maxHeight * 0.02).clamp(5.0, 8.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                context.read<FlashcardBloc>().add(
                                      SpeakFlashcardText(word.word),
                                    );
                              },
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  word.word.isNotEmpty
                                      ? word.word
                                      : 'Word not found',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.02,
                                    color: Color(0xFF191C1E),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildPhoneticRow(context),
                      if (word.definition.isNotEmpty)
                        Expanded(
                          child: _buildDefinitionSection(),
                        )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhoneticRow(BuildContext context) {
    return Text(
      word.phonetic.isNotEmpty ? word.phonetic : '/${word.word}/',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF535C89),
      ),
    );
  }

  Widget _buildDefinitionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              word.definition,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: Color(0xFF191C1E),
              ),
            ),
          ),
        ),
        const Text(
          'example',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
            color: Color(0xFF454651),
          ),
        ),
      ],
    );
  }
}
