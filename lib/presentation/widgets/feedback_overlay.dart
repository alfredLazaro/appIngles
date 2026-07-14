import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';

class FeedbackOverlay extends StatefulWidget {
  final String text;
  final bool isCorrect;
  final Duration displayDuration;
  final Duration fadeDuration;
  final VoidCallback onDismiss;

  const FeedbackOverlay({
    super.key,
    required this.text,
    required this.isCorrect,
    this.displayDuration = const Duration(seconds: 2),
    this.fadeDuration = AppDurations.matchingFade,
    required this.onDismiss,
  });

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startDismissSequence();
  }

  void _startDismissSequence() {
    Future.delayed(widget.displayDuration, () {
      if (!mounted) return;
      setState(() => _opacity = 0.0);
      Future.delayed(widget.fadeDuration, () {
        if (!mounted) return;
        widget.onDismiss();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.fadeDuration,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: widget.isCorrect
            ? AppColors.successLight.withValues(alpha: 0.3)
            : AppColors.errorLight,
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.isCorrect ? AppColors.success : AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
