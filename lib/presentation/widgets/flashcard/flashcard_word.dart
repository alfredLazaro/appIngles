import 'package:flutter/material.dart';

/// Widget Flashcard simple - muestra toda la info en el frente
class WordFlashcard extends StatelessWidget {
  final FlashcardWord word;
  final List<FlashcardImage> images;
  final Color backgroundColor;
  final Color textColor;

  const WordFlashcard({
    super.key,
    required this.word,
    required this.images,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            padding: EdgeInsets.all(constraints.maxHeight * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ✅ Imágenes
                FlashcardImageWidget(
                  images: images,
                  height: constraints.maxHeight * 0.35,
                ),
                
                SizedBox(height: constraints.maxHeight * 0.02),
                
                // ✅ Palabra principal
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      word.word.isNotEmpty ? word.word : 'Word not found',
                      style: TextStyle(
                        fontSize: constraints.maxHeight * 0.08,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                SizedBox(height: constraints.maxHeight * 0.02),
                
                // ✅ Definición
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            color: textColor.withOpacity(0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Definición:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        word.definition.isNotEmpty
                            ? word.definition
                            : 'No definition available',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: constraints.maxHeight * 0.015),
                
                // ✅ Oración de ejemplo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_quote,
                            color: textColor.withOpacity(0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ejemplo:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        word.sentence.isNotEmpty
                            ? word.sentence
                            : 'No sentence available',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // ✅ Contador de aprendizaje (opcional, en la parte inferior)
                if (word.learnCount > 0)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sync,
                            color: textColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Revisado ${word.learnCount} veces',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}