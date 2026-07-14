import 'package:flutter/material.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';

String _titleForType(PracticeType type) {
  switch (type) {
    case PracticeType.flashcard:
      return 'Flashcards - Resultados';
    case PracticeType.sentence:
      return 'Ordenar Oraciones - Resultados';
    case PracticeType.listening:
      return 'Listening - Resultados';
    case PracticeType.matching:
      return 'Emparejar - Resultados';
    case PracticeType.matchingDefinition:
      return 'Emparejar-Definición - Resultados';
    case PracticeType.spelling:
      return 'Spelling - Resultados';
  }
}

class PracticeResultsWidget extends StatelessWidget {
  final PracticeType practiceType;
  final int totalItems;
  final int correctItems;
  final List<FlashcardWord> words;
  final Map<int, int> learnCountUpdates;
  final VoidCallback onFinish;
  final Color? accentColor;
  final bool showDetailList;

  const PracticeResultsWidget({
    super.key,
    required this.practiceType,
    required this.totalItems,
    required this.correctItems,
    required this.words,
    required this.learnCountUpdates,
    required this.onFinish,
    this.accentColor,
    this.showDetailList = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        totalItems == 0 ? 0 : (correctItems / totalItems * 100);
    final isPerfect = correctItems == totalItems;
    final color = accentColor ?? (isPerfect ? Colors.green : Colors.orange);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForType(practiceType)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: isPerfect ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              isPerfect ? '¡Perfecto!' : 'Práctica completada',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$correctItems de $totalItems aciertos',
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
                color: color,
              ),
            ),
            if (showDetailList && words.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detalle por palabra:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: words.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final word = words[index];
                    final finalCount =
                        learnCountUpdates[word.id] ?? word.learnCount;
                    final points = finalCount - word.learnCount;
                    final Color pointsColor;
                    final IconData pointsIcon;
                    if (points > 0) {
                      pointsColor = Colors.green;
                      pointsIcon = Icons.arrow_upward;
                    } else if (points < 0) {
                      pointsColor = Colors.red;
                      pointsIcon = Icons.arrow_downward;
                    } else {
                      pointsColor = Colors.grey;
                      pointsIcon = Icons.remove;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              word.word,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Icon(pointsIcon, size: 18, color: pointsColor),
                          const SizedBox(width: 4),
                          Text(
                            points >= 0 ? '+$points' : '$points',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: pointsColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onFinish,
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
