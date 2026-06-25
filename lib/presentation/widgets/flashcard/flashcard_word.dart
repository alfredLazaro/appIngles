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
                  padding: EdgeInsets.all(
                    (constraints.maxHeight * 0.04).clamp(20.0, 32.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            word.word.isNotEmpty ? word.word : 'Word not found',
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
                      const SizedBox(height: 12),
                      _buildPhoneticRow(context),
                      const SizedBox(height: 24),
                      _buildDefinitionSection(),
                      const Spacer(),
                      Text(
                        'Tap to see definition',
                        style: TextStyle(
                          fontSize: (constraints.maxHeight * 0.02).clamp(10.0, 13.0),
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF454651).withOpacity(0.4),
                        ),
                      ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          word.phonetic.isNotEmpty ? word.phonetic : '/${word.word}/',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0xFF535C89),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFC0C9FD).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.volume_up,
              size: 22,
              color: Color(0xFF535C89),
            ),
            onPressed: () {
              context.read<FlashcardBloc>().add(
                    SpeakFlashcardText(word.word),
                  );
            },
            tooltip: 'Escuchar',
          ),
        ),
      ],
    );
  }

  Widget _buildDefinitionSection() {
    if (word.definition.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DEFINITION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
            color: Color(0xFF454651),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          word.definition,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: Color(0xFF191C1E),
          ),
        ),
      ],
    );
  }
}
