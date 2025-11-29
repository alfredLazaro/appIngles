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
          ElevatedButton.icon(
            onPressed: onLearned,
            icon: Icon(Icons.check, size: iconSize),
            label: Text(
              FlashcardConstants.learnedButtonLabel,
              style: TextStyle(fontSize: fontSize),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: onReset,
            icon: Icon(Icons.restart_alt, size: iconSize),
            label: Text(
              FlashcardConstants.againButtonLabel,
              style: TextStyle(fontSize: fontSize),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
