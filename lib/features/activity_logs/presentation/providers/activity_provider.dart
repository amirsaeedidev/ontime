import 'package:flutter/foundation.dart';
import '../../../../core/providers/db_bound_provider.dart';
import '../../../../data/mock/app_database.dart';
import '../../../../data/models/activity_log.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/repositories/activity_repository.dart';

/// گزارش فعالیت‌ها با فیلتر نوع و جست‌وجو.
class ActivityProvider extends DbBoundProvider {
  ActivityProvider(this._repository, AppDatabase db) : super(db) {
    load();
  }

  final ActivityRepository _repository;

  List<ActivityLog> _logs = const [];
  List<ActivityLog> _recent = const [];
  ActivityType? _type;
  String _query = '';
  bool _loading = true;
  String? _loadError;

  List<ActivityLog> get logs => _logs;
  List<ActivityLog> get recent => _recent;
  ActivityType? get type => _type;
  String get query => _query;
  bool get loading => _loading;
  String? get loadError => _loadError;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _logs = await _repository.fetchLogs(type: _type, query: _query);
      _recent = await _repository.fetchRecent(limit: 6);
    } catch (error) {
      _loadError = '$error';
      debugPrint('[ONTIME][Activity] load failed: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void onDatabaseChanged() {
    _refresh();
  }

  Future<void> _refresh() async {
    _logs = await _repository.fetchLogs(type: _type, query: _query);
    _recent = await _repository.fetchRecent(limit: 6);
    notifyListeners();
  }

  void filterType(ActivityType? type) {
    _type = type;
    load();
  }

  void search(String query) {
    _query = query;
    load();
  }
}
