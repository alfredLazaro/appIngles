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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // TextField ocupa el espacio disponible
              Expanded(
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
              // Espacio entre TextField y botón
              const SizedBox(width: 10),
              // Botón Guardar
              ElevatedButton(
                onPressed: onSave,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  backgroundColor: Colors.blue, // Color personalizado
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
