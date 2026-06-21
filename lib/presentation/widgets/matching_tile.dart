import 'package:flutter/material.dart';

class MatchingTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMatched;
  final bool? isCorrect;
  final Color color;
  final VoidCallback? onTap;
  final bool shrinkWrap;

  const MatchingTile({
    super.key,
    required this.text,
    this.isSelected = false,
    this.isMatched = false,
    this.isCorrect,
    this.color = Colors.teal,
    this.onTap,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    if (isMatched) {
      if (isCorrect == true) {
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
      } else if (isCorrect == false) {
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
      } else {
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade600;
      }
    } else if (isSelected) {
      backgroundColor = color.withValues(alpha: 0.2);
      textColor = color;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: isMatched && isCorrect != false ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : isMatched
                    ? (isCorrect == true
                        ? Colors.green
                        : isCorrect == false
                            ? Colors.red
                            : Colors.grey.shade300)
                    : Colors.grey.shade300,
            width: isSelected || isMatched ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected || (isMatched && isCorrect == true))
              BoxShadow(
                color: (isMatched ? Colors.green : color).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (shrinkWrap)
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isSelected || isMatched ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              )
            else
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected || isMatched
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ),
            if (icon != null)
              Icon(
                icon,
                size: 24,
                color: isCorrect == true ? Colors.green : Colors.red,
              ),
          ],
        ),
      ),
    );
  }
}
