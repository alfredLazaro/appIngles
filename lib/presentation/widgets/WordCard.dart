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
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: SizedBox(
          width: 56,
          height: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
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
        title: Text(
          word.word,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          word.definition,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: onSpeak,
        ),
      ),
    );
  }
}
