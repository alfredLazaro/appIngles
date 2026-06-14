import 'package:flutter/material.dart';

class AuthorInfoButton extends StatelessWidget {
  final String? author;
  final String? source;

  const AuthorInfoButton({
    super.key,
    required this.author,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Autor: ${author ?? "Desconocido"}\nFuente: ${source ?? "Desconocida"}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.info_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
