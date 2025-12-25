import 'package:flutter/material.dart';

/// Widget reutilizable para controles de navegación de páginas
class PageNavigationControls extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String? previousLabel;
  final String? nextLabel;
  final String? finalLabel;
  final Widget? centerWidget;
  final Color? nextButtonColor;
  final IconData? previousIcon;
  final IconData? nextIcon;
  final IconData? finalIcon;

  const PageNavigationControls({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    this.previousLabel = 'Anterior',
    this.nextLabel = 'Siguiente',
    this.finalLabel = 'Finalizar',
    this.centerWidget,
    this.nextButtonColor,
    this.previousIcon = Icons.arrow_back,
    this.nextIcon = Icons.arrow_forward,
    this.finalIcon = Icons.check_circle,
  });

  bool get isFirstPage => currentIndex == 0;
  bool get isLastPage => currentIndex >= totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ Botón Anterior
          ElevatedButton.icon(
            onPressed: !isFirstPage ? onPrevious : null,
            icon: Icon(previousIcon),
            label: Text(previousLabel!),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),

          // ✅ Widget central (contador o custom)
          centerWidget ??
              _DefaultCenterWidget(
                currentIndex: currentIndex,
                totalPages: totalPages,
              ),

          // ✅ Botón Siguiente/Finalizar
          ElevatedButton.icon(
            onPressed: onNext,
            icon: Icon(isLastPage ? finalIcon : nextIcon),
            label: Text(isLastPage ? finalLabel! : nextLabel!),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLastPage 
                  ? (nextButtonColor ?? Colors.green)
                  : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget por defecto para el centro (contador simple)
class _DefaultCenterWidget extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const _DefaultCenterWidget({
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${currentIndex + 1} / $totalPages',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}