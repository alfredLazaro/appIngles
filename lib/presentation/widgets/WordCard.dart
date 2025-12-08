import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  final WordWithImage word;
  final VoidCallback onSpeak;

  const WordCard({
    super.key,
    required this.word,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen en el borde izquierdo (sin margen)
          SizedBox(
            width: 80, // Más ancha que antes
            height: double.infinity, // Toma toda la altura
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: word.tinyImageUrl != null && word.tinyImageUrl!.isNotEmpty
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
                          size: 32, // Más grande
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 32, // Más grande
                      ),
                    ),
            ),
          ),
          
          // Contenido de texto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título con audio
                  GestureDetector(
                    onTap: onSpeak,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            word.word,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.volume_up,
                          size: 18,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Definición
                  Text(
                    word.definition,
                    style: const TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
