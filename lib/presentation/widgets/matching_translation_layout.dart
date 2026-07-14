import 'package:flutter/material.dart';
import 'package:first_app/presentation/bloc/matching/matching_state.dart';
import 'package:first_app/presentation/widgets/matching_tile.dart';
import 'package:first_app/presentation/widgets/matching_animation_controller.dart';

class MatchingTranslationLayout extends StatelessWidget {
  final MatchingRoundReady state;
  final MatchingAnimationController controller;
  final void Function(int index) onLeftTap;
  final void Function(int index) onRightTap;

  const MatchingTranslationLayout({
    super.key,
    required this.state,
    required this.controller,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildColumn(
            title: 'Palabras',
            children: List.generate(
              state.round.words.length,
              (i) => AnimatedOpacity(
                opacity: controller.fadingOutWords.contains(i) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: MatchingTile(
                  text: state.round.words[i].word,
                  isSelected: state.selectedLeftIndex == i,
                  isMatched: state.matchedWordIndices.contains(i),
                  isCorrect:
                      state.matchedWordIndices.contains(i) ? true : null,
                  showShake: controller.shakingPair != null &&
                      controller.shakingPair!.left == i,
                  onTap: () => onLeftTap(i),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildColumn(
            title: 'Traducciones',
            children: List.generate(
              state.round.translations.length,
              (i) => AnimatedOpacity(
                opacity:
                    controller.fadingOutTranslations.contains(i) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: MatchingTile(
                  text: state.round.translations[i].wordTranslate,
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
              color: Color(0xFF464556),
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
