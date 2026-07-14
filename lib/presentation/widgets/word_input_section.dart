import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';

class WordInputSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool isLoading;
  final VoidCallback onListen;
  final VoidCallback onSave;

  const WordInputSection({
    super.key,
    required this.controller,
    required this.isListening,
    required this.onListen,
    required this.onSave,
    this.isLoading = false,
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
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onSave(),
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
                onPressed: isLoading ? null : onSave,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppLayout.radiusSmall),
                  ),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
