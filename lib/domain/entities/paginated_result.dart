import 'package:equatable/equatable.dart';

class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final bool hasNextPage;

  const PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props =>
      [items, currentPage, pageSize, totalItems, hasNextPage];
}
