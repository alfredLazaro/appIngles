import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final PageController pageController;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 0
              ? () => pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  )
              : null,
        ),
        Text('Página ${currentPage + 1} de $pageCount'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < pageCount - 1
              ? () => pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  )
              : null,
        ),
      ],
    );
  }
}
