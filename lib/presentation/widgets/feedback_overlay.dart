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
    this.displayDuration = const Duration(seconds: 1),
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
    return Center(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: widget.fadeDuration,
        child: Container(
          width: 170,
          height: 130,
          decoration: BoxDecoration(
            color: widget.isCorrect
                ? AppColors.successLight.withValues(alpha: 0.5)
                : AppColors.errorLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (widget.isCorrect ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isCorrect ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
