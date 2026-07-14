import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';

class MatchingProgressBar extends StatelessWidget {
  final int matched;
  final int total;
  final int roundIndex;
  final int totalRounds;

  const MatchingProgressBar({
    super.key,
    required this.matched,
    required this.total,
    required this.roundIndex,
    required this.totalRounds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : matched / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text(
                'Set Progress',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.subtitleGrey,
                  fontFamily: 'Nunito Sans',
                ),
              ),
              Text(
                'Round ${roundIndex + 1} of $totalRounds',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.subtitleGrey,
                  letterSpacing: 0.5,
                ),
              ),
                ],
              ),
              Text(
                '$matched/$total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.progressGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppLayout.radiusPill),
            child: Container(
              height: 12,
              width: double.infinity,
              color: AppColors.progressTrack,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.progressGreen,
                      borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppLayout.radiusPill),
                      bottomLeft: Radius.circular(AppLayout.radiusPill),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
