import 'package:flutter/material.dart';

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
                  color: Color(0xFF767587),
                  fontFamily: 'Nunito Sans',
                ),
              ),
              Text(
                'Round ${roundIndex + 1} of $totalRounds',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF767587),
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
                  color: Color(0xFF22c55e),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              height: 12,
              width: double.infinity,
              color: const Color(0xFFE0E0FF),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF22c55e),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9999),
                      bottomLeft: Radius.circular(9999),
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
