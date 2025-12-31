import 'package:flutter/material.dart';

class LearnProgressIndicator extends StatelessWidget {
  final int learnValue;
  final double? width;
  final double? height;

  const LearnProgressIndicator({
    super.key,
    required this.learnValue,
    this.width = 60.0,
    this.height = 4.0,
  });

  Color _getProgressColor() {
    if (learnValue == 0) {
      return Colors.white;
    } else if (learnValue >= 1 && learnValue <= 70) {
      return Colors.orange;
    } else if (learnValue >= 71 && learnValue <= 100) {
      return Colors.green;
    }
    return Colors.grey; // Fallback color
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _getProgressColor(),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
