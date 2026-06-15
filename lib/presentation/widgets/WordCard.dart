import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/presentation/widgets/learn_progress_indicator.dart';
import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  final WordWithImage word;
  final VoidCallback onSpeak;
  final VoidCallback? onTapImage;

  const WordCard({
    super.key,
    required this.word,
    required this.onSpeak,
    this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            GestureDetector(
              onTap: onTapImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 75,
                  height: 75,
                  child: word.tinyImageUrl != null &&
                          word.tinyImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: word.tinyImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12), // Espacio entre imagen y texto
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onSpeak,
                          child: Text(
                            word.word,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Progress indicator next to the word
                      LearnProgressIndicator(learnValue: word.learn),
                      const SizedBox(width: 3),
                      SizedBox(
                        width: 36, // Enough for "100 %"
                        child: Text(
                          '${word.learn} %',
                          textAlign: TextAlign
                              .right, // Align to the right for consistency
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    word.definition,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2, // ← Cambia a 1 o 2 según prefieras
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
