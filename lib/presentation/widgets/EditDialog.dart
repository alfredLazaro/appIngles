import 'package:flutter/material.dart';

class EditSentenceDialog extends StatelessWidget {
  final String initialSentence;
  final Function(String) onUpdate;
  final TextEditingController _controller;

  EditSentenceDialog({
    super.key,
    required this.initialSentence,
    required this.onUpdate,
  }) : _controller = TextEditingController(text: initialSentence);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar Sentence"),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: "Nueva sentence",
        ),
        minLines: 1,
        maxLines: 2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            onUpdate(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text("Actualizar"),
        ),
      ],
    );
  }
}
