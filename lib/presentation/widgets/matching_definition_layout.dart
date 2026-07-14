import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/presentation/bloc/matching/matching_state.dart';
import 'package:first_app/presentation/widgets/matching_tile.dart';
import 'package:first_app/presentation/widgets/matching_animation_controller.dart';

class MatchingDefinitionLayout extends StatelessWidget {
  final MatchingRoundReady state;
  final MatchingAnimationController controller;
  final void Function(int index) onLeftTap;
  final void Function(int index) onRightTap;

  const MatchingDefinitionLayout({
    super.key,
    required this.state,
    required this.controller,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  'Palabras',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        state.round.words.length,
                        (i) => AnimatedOpacity(
                          opacity:
                              controller.fadingOutWords.contains(i) ? 0.0 : 1.0,
                          duration: AppDurations.matchingFade,
                          child: MatchingTile(
                            text: state.round.words[i].word,
                            shrinkWrap: true,
                            isSelected: state.selectedLeftIndex == i,
                            isMatched: state.matchedWordIndices.contains(i),
                            isCorrect: state.matchedWordIndices.contains(i)
                                ? true
                                : null,
                            showShake: controller.shakingPair != null &&
                                controller.shakingPair!.left == i,
                            onTap: () => onLeftTap(i),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildColumn(
            title: 'Definiciones',
            children: List.generate(
              state.round.definitions!.length,
              (i) => AnimatedOpacity(
                opacity: controller.fadingOutTranslations.contains(i)
                    ? 0.0
                    : 1.0,
                duration: const Duration(milliseconds: 500),
                child: MatchingTile(
                  text: state.round.definitions![i],
                  isSelected: state.selectedRightIndex == i,
                  isMatched: state.matchedTranslationIndices.contains(i),
                  isCorrect: state.matchedTranslationIndices.contains(i)
                      ? true
                      : null,
                  showShake: controller.shakingPair != null &&
                      controller.shakingPair!.right == i,
                  onTap: () => onRightTap(i),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColumn({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.matchingTitle,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
