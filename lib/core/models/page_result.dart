/// نتیجه صفحه‌بندی‌شده برای درخواست‌های سازگار با Supabase (range/limit).
class PageResult<T> {
  const PageResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;

  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();
  bool get hasNext => page < totalPages;
  bool get hasPrevious => page > 1;

  static PageResult<T> empty<T>({int pageSize = 10}) =>
      PageResult<T>(items: const [], total: 0, page: 1, pageSize: pageSize);

  PageResult<R> map<R>(R Function(T item) transform) => PageResult<R>(
        items: items.map(transform).toList(),
        total: total,
        page: page,
        pageSize: pageSize,
      );
}
