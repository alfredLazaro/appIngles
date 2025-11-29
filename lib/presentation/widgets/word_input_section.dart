import 'package:flutter/material.dart';

class WordInputSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onListen;
  final VoidCallback onSave;

  const WordInputSection({
    super.key,
    required this.controller,
    required this.isListening,
    required this.onListen,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Palabra a aprender'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Escribe la palabra',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: onListen,
                icon: Icon(isListening ? Icons.mic : Icons.mic_none),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onSave,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
