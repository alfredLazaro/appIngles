import 'dart:math';
import 'package:flutter/material.dart';

class MatchingTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMatched;
  final bool? isCorrect;
  final Color color;
  final VoidCallback? onTap;
  final bool shrinkWrap;
  final bool showShake;

  const MatchingTile({
    super.key,
    required this.text,
    this.isSelected = false,
    this.isMatched = false,
    this.isCorrect,
    this.color = Colors.teal,
    this.onTap,
    this.shrinkWrap = false,
    this.showShake = false,
  });

  static const Color _primary = Color.fromARGB(255, 39, 38, 63);
  static const Color _tertiary = Color(0xFF006934);
  static const Color _tertiaryContainer = Color(0xFF6BFE9C);
  static const Color _error = Color(0xFFBA1A1A);
  static const Color _errorContainer = Color(0xFFFFDAD6);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1B1C1C);
  static const Color _outlineVariant = Color(0xFFC6C4D8);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border border;
    List<BoxShadow> shadows;

    if (isMatched && isCorrect == true) {
      bgColor = _tertiaryContainer;
      textColor = _tertiary;
      border = Border.all(color: _tertiary, width: 0.5);
      shadows = [];
    } else if (isMatched && isCorrect == false) {
      bgColor = _errorContainer;
      textColor = _error;
      border = Border.all(color: _error, width: 0.5);
      shadows = [];
    } else if (isMatched) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade600;
      border = Border.all(color: Colors.grey.shade300, width: 0.5);
      shadows = [];
    } else if (isSelected) {
      bgColor = const Color.fromARGB(255, 185, 213, 240);
      textColor = _primary;
      border = Border.all(color: _primary, width: 0.5);
      shadows = [
        BoxShadow(
          color: _primary.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
    } else {
      bgColor = _surfaceContainerLowest;
      textColor = _onSurface;
      border = Border.all(color: _outlineVariant, width: 0.5);
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 8),
        ),
      ];
    }

    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
        boxShadow: shadows,
      ),
      child: Row(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if (shrinkWrap)
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    isSelected || isMatched ? FontWeight.bold : FontWeight.w400,
                color: textColor,
              ),
            )
          else
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected || isMatched
                      ? FontWeight.bold
                      : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
        ],
      ),
    );

    final gestureTile = GestureDetector(
      onTap: isMatched && isCorrect != false ? null : onTap,
      child: tile,
    );

    if (showShake) {
      return _ShakeWidget(child: gestureTile);
    }

    return gestureTile;
  }
}

class _ShakeWidget extends StatefulWidget {
  final Widget child;
  const _ShakeWidget({required this.child});

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final shake = sin(_animation.value * 4 * pi) * 4;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
