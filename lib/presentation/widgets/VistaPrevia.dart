import 'package:flutter/material.dart';

class VistaPrevia extends StatelessWidget {
  final List<Map<String, dynamic>> definitiones;
  final Function(Map<String, dynamic>) onConfirm;
  const VistaPrevia({
    super.key,
    required this.definitiones,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("previsulaizar definitiones"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: definitiones.length,
              itemBuilder: (context, index) {
                final item = definitiones[index];
                return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                        title: Text(item['definition']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Palabra: ${item['word']}"),
                            Text("Traduccion: ${item['wordTralat'] ?? '---'}"),
                            Text("Ejemplo: ${item['sentence']}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => onConfirm(item),
                        )));
              }),
        ));
  }
}
