import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmationDialog(
  BuildContext context, {
  String title = 'Eliminar palabra',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: const Text('¿Estás seguro de eliminar esta palabra?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return result ?? false;
}
