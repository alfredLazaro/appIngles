import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:flutter/material.dart';
import 'word_list_item.dart';
import 'pagination_controls.dart';

class WordListSection extends StatelessWidget {
  final List<WordSummary> words;
  final int currentPage;
  final PageController pageController;
  final Function(WordSummary) onEdit;
  final Function(String) onCopy;
  final Function(int) onDelete;
  final Function(int) onPageChanged;

  const WordListSection({
    super.key,
    required this.words,
    required this.currentPage,
    required this.pageController,
    required this.onEdit,
    required this.onCopy,
    required this.onDelete,
    required this.onPageChanged,
  });

  int get _pageCount => (words.length / 3).ceil();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: _pageCount,
              onPageChanged: onPageChanged,
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 3;
                final endIndex = (startIndex + 3).clamp(0, words.length);
                final displayedWords = words.sublist(startIndex, endIndex);

                return ListView.builder(
                  itemCount: displayedWords.length,
                  itemBuilder: (context, index) {
                    return WordListItem(
                      word: displayedWords[index],
                      onEdit: () => onEdit(displayedWords[index]),
                      onCopy: () => onCopy(displayedWords[index].sentence),
                      onDelete: () => onDelete(displayedWords[index].id),
                    );
                  },
                );
              },
            ),
          ),
          PaginationControls(
            currentPage: currentPage,
            pageCount: _pageCount,
            pageController: pageController,
          ),
        ],
      ),
    );
  }
}
