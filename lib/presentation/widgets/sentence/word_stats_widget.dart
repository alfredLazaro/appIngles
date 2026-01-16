// lib/presentation/widgets/word_list/word_stats_widget.dart

import 'package:flutter/material.dart';
import 'package:first_app/domain/entities/word_stats.dart';

class WordStatsWidget extends StatelessWidget {
  final WordStats stats;
  final bool compact;

  const WordStatsWidget({
    super.key,
    required this.stats,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactView(context);
    }
    return _buildExpandedView(context);
  }

  Widget _buildCompactView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatChip(
            icon: Icons.library_books,
            value: stats.totalWords,
            color: Colors.black,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.fiber_new,
            value: stats.newWords,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.fitness_center,
            value: stats.practiceWords,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.check_circle,
            value: stats.learnedWords,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCard(
                icon: Icons.library_books,
                label: 'Total',
                value: stats.totalWords,
                color: Colors.blue,
              ),
              _StatCard(
                icon: Icons.fiber_new,
                label: 'Nuevas',
                value: stats.newWords,
                color: Colors.orange,
                percentage: stats.newPercentage,
              ),
              _StatCard(
                icon: Icons.fitness_center,
                label: 'Practicando',
                value: stats.practiceWords,
                color: Colors.purple,
                percentage: stats.practicePercentage,
              ),
              _StatCard(
                icon: Icons.check_circle,
                label: 'Aprendidas',
                value: stats.learnedWords,
                color: Colors.green,
                percentage: stats.learnedPercentage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final double? percentage;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        if (percentage != null)
          Text(
            '${percentage!.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
      ],
    );
  }
}
