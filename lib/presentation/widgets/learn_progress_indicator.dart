import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';

class LearnProgressIndicator extends StatelessWidget {
  final int learnValue;
  final double? width;
  final double? height;
  final Color backgroundColor;

  const LearnProgressIndicator({
    super.key,
    required this.learnValue,
    this.width = 80.0,
    this.height = 4.0,
    this.backgroundColor = Colors.white,
  });

  Color _getProgressColor() {
    if (learnValue == 0) {
      return Colors.transparent;
    } else if (learnValue >= AppLimits.learnLowMin && learnValue <= AppLimits.learnLowMax) {
      return Colors.red;
    } else if (learnValue >= AppLimits.learnMidMin && learnValue <= AppLimits.learnMidMax) {
      return Colors.orange;
    } else if (learnValue >= AppLimits.learnHighMin && learnValue <= AppLimits.learnHighMax) {
      return Colors.green;
    }
    return Colors.grey; // Fallback color
  }

  @override
  Widget build(BuildContext context) {
    // Clamp the value between 0 and 100
    final clampedValue = learnValue.clamp(0, AppLimits.learnMaxValue);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: (width! * clampedValue / 100),
          height: height,
          decoration: BoxDecoration(
            color: _getProgressColor(),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
