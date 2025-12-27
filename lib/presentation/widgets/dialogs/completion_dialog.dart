import 'package:flutter/material.dart';

class CompletionDialog extends StatelessWidget {
  final int totalItems;
  final int learnedCount;
  final String itemName; // "palabras", "frases", "ejercicios", etc.
  final VoidCallback onFinish;
  final VoidCallback onRepeat;
  final String? customTitle;
  final Color? primaryColor;

  const CompletionDialog({
    Key? key,
    required this.totalItems,
    required this.learnedCount,
    this.itemName = 'palabras',
    required this.onFinish,
    required this.onRepeat,
    this.customTitle,
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = primaryColor ?? theme.primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado
            _buildHeader(context, color),
            const SizedBox(height: 20),
            
            // Estadísticas
            _buildStatistics(context),
            const SizedBox(height: 20),
            
            // Contenedor de progreso
            _buildProgressContainer(context),
            const SizedBox(height: 24),
            
            // Botones de acción
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.celebration,
          color: color,
          size: 32,
        ),
        const SizedBox(width: 12),
        Text(
          customTitle ?? '¡Práctica completada!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return Text(
      'Has practicado $totalItems $itemName.',
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$learnedCount $itemName marcadas como aprendidas',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onFinish,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Finalizar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onRepeat,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.replay, size: 20),
            label: const Text('Repetir'),
          ),
        ),
      ],
    );
  }
}