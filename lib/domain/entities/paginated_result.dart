class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final bool hasNextPage;

  PaginatedResult({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.hasNextPage,
  });
}
