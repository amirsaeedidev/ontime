import 'package:flutter/foundation.dart';
import '../../../../core/providers/db_bound_provider.dart';
import '../../../../data/mock/app_database.dart';
import '../../../../data/models/dashboard_stats.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/repositories/dashboard_repository.dart';

/// گزارش‌های درآمد و عملکرد.
class ReportsProvider extends DbBoundProvider {
  ReportsProvider(this._repository, AppDatabase db) : super(db) {
    load();
  }

  final DashboardRepository _repository;

  List<RevenuePoint> _revenueSeries = const [];
  List<RevenuePoint> _serviceRevenue = const [];
  bool _loading = true;
  String? _loadError;
  int _months = 6;

  List<RevenuePoint> get revenueSeries => _revenueSeries;
  List<RevenuePoint> get serviceRevenue => _serviceRevenue;
  bool get loading => _loading;
  String? get loadError => _loadError;
  int get months => _months;

  num get totalRevenue => _revenueSeries.fold<num>(0, (sum, p) => sum + p.value);
  num get averageRevenue => _revenueSeries.isEmpty ? 0 : totalRevenue / _revenueSeries.length;
  num get bestMonth => _revenueSeries.isEmpty
      ? 0
      : _revenueSeries.map((p) => p.value).reduce((a, b) => a > b ? a : b);

  Map<String, int> get statusCounts => {
        for (final status in AppointmentStatus.values)
          status.label: db.appointments.where((a) => a.status == status).length,
      };

  Map<String, num> get employeeRevenue {
    final map = <String, num>{};
    for (final a in db.appointments.where((a) => a.status == AppointmentStatus.completed)) {
      map[a.employeeName] = (map[a.employeeName] ?? 0) + a.price;
    }
    return map;
  }

  int get totalAppointments => db.appointments.length;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _revenueSeries = await _repository.fetchRevenueSeries(months: _months);
      _serviceRevenue = await _repository.fetchServiceRevenue(limit: 5);
    } catch (error) {
      _loadError = '$error';
      debugPrint('[ONTIME][Reports] load failed: $error');
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
    _revenueSeries = await _repository.fetchRevenueSeries(months: _months);
    _serviceRevenue = await _repository.fetchServiceRevenue(limit: 5);
    notifyListeners();
  }

  Future<void> setMonths(int months) async {
    _months = months;
    await load();
  }
}
