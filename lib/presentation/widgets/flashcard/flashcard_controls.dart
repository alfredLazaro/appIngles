import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';

class FlashcardControls extends StatelessWidget {
  final double height;
  final double fontSize;
  final double iconSize;
  final VoidCallback onLearned;
  final VoidCallback onReset;

  const FlashcardControls({
    super.key,
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.onLearned,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            icon: Icons.chevron_left,
            label: FlashcardConstants.againButtonLabel,
            color: const Color(0xFF535C89),
            onPressed: onReset,
          ),
          _buildPrimaryButton(
            icon: Icons.check_circle,
            label: FlashcardConstants.learnedButtonLabel,
            onPressed: onLearned,
          ),
          _buildNavButton(
            icon: Icons.chevron_right,
            label: FlashcardConstants.againButtonLabel,
            color: const Color(0xFF535C89),
            onPressed: onReset,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
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
                Icon(
                  icon,
                  size: iconSize,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
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
