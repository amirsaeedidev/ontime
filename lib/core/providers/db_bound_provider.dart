import 'package:flutter/foundation.dart';

import '../../data/mock/app_database.dart';

/// پایه Providerهایی که باید با تغییرات پایگاه‌داده همگام شوند.
abstract class DbBoundProvider extends ChangeNotifier {
  DbBoundProvider(this.db) {
    db.addListener(_handleDbChange);
  }

  @protected
  final AppDatabase db;

  bool _disposed = false;

  void _handleDbChange() {
    if (_disposed) return;
    onDatabaseChanged();
  }

  /// در کلاس‌های فرزند برای بارگذاری مجدد داده‌ها پیاده‌سازی می‌شود.
  @protected
  void onDatabaseChanged() {}

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    db.removeListener(_handleDbChange);
    super.dispose();
  }
}
