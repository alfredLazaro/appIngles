import 'package:flutter/material.dart';
import 'package:first_app/presentation/bloc/matching/matching_state.dart';

class MatchingResultsWidget extends StatelessWidget {
  final MatchingCompleted state;
  final int totalPairs;
  final VoidCallback? onBack;

  const MatchingResultsWidget({
    super.key,
    required this.state,
    required this.totalPairs,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        totalPairs == 0 ? 0 : (state.totalCorrect / totalPairs * 100);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emparejar - Resultados'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 80,
                color: state.totalCorrect == totalPairs
                    ? Colors.amber
                    : Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                state.totalCorrect == totalPairs
                    ? '¡Perfecto!'
                    : 'Práctica completada',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${state.totalCorrect} de $totalPairs aciertos',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: state.totalCorrect == totalPairs
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onBack ?? () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
