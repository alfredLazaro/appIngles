import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';

class FlashcardControls extends StatelessWidget {
  final double height;
  final double fontSize;
  final double iconSize;
  final VoidCallback onLearned;

  const FlashcardControls({
    super.key,
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.onLearned,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPrimaryButton(
            label: FlashcardConstants.learnedButtonLabel,
            onPressed: onLearned,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF5C6BC0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
