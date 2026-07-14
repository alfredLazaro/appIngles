import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';

class FeedbackArea extends StatelessWidget {
  final bool? isCorrect;
  final String? correctAnswer;

  const FeedbackArea({
    super.key,
    this.isCorrect,
    this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    if (isCorrect == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: FlashcardConstants.successContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 20,
              color: AppColors.success,
            ),
            SizedBox(width: 8),
            Text(
              '¡Correcto! Excelente memoria.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: FlashcardConstants.successDark,
              ),
            ),
          ],
        ),
      );
    }

    if (isCorrect == false) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 20,
              color: AppColors.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Correcto: ${correctAnswer ?? ""}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8),
          Text(
            'Toca comprobar para validar',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
