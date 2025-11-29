import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:flutter/material.dart';

class WordListItem extends StatelessWidget {
  final WordSummary word;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const WordListItem({
    super.key,
    required this.word,
    required this.onEdit,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(word.word),
      subtitle: Text(word.sentence),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: onCopy,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
