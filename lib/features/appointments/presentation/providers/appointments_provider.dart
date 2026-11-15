import 'package:flutter/foundation.dart';
import '../../../../core/models/page_result.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../core/providers/db_bound_provider.dart';
import '../../../../data/mock/app_database.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/repositories/appointment_repository.dart';

/// جست‌وجو، فیلتر، صفحه‌بندی و عملیات نوبت‌ها.
class AppointmentsProvider extends DbBoundProvider {
  AppointmentsProvider(this._repository, AppDatabase db) : super(db) {
    load();
  }

  final AppointmentRepository _repository;

  PageResult<Appointment> _page = PageResult.empty(pageSize: 8);
  AppointmentFilter _filter = const AppointmentFilter();
  bool _loading = true;
  String? _loadError;
  bool _busy = false;
  int _pageNumber = 1;
  int _pageSize = 8;
  bool _ascending = false;

  PageResult<Appointment> get page => _page;
  List<Appointment> get items => _page.items;
  AppointmentFilter get filter => _filter;
  bool get loading => _loading;
  String? get loadError => _loadError;
  bool get busy => _busy;
  int get pageNumber => _pageNumber;
  int get pageSize => _pageSize;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _page = await _repository.fetchAppointments(
        filter: _filter,
        page: _pageNumber,
        pageSize: _pageSize,
        ascending: _ascending,
      );
    } catch (error) {
      _loadError = '$error';
      debugPrint('[ONTIME][Appointments] load failed: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void onDatabaseChanged() {
    _loadSilently();
  }

  Future<void> _loadSilently() async {
    final page = await _repository.fetchAppointments(
      filter: _filter,
      page: _pageNumber,
      pageSize: _pageSize,
      ascending: _ascending,
    );
    // اگر صفحه فعلی خالی شد به صفحه قبل برگرد.
    if (page.items.isEmpty && _pageNumber > 1) {
      _pageNumber = (page.total / _pageSize).ceil().clamp(1, 999);
      _page = await _repository.fetchAppointments(
        filter: _filter,
        page: _pageNumber,
        pageSize: _pageSize,
        ascending: _ascending,
      );
    } else {
      _page = page;
    }
    notifyListeners();
  }

  void setQuery(String query) {
    _filter = _filter.copyWith(query: query);
    _pageNumber = 1;
    load();
  }

  void setStatus(AppointmentStatus? status) {
    _filter = status == null ? _filter.copyWith(clearStatus: true) : _filter.copyWith(status: status);
    _pageNumber = 1;
    load();
  }

  void setService(String? serviceId) {
    _filter = serviceId == null ? _filter.copyWith(clearService: true) : _filter.copyWith(serviceId: serviceId);
    _pageNumber = 1;
    load();
  }

  void setEmployee(String? employeeId) {
    _filter = employeeId == null ? _filter.copyWith(clearEmployee: true) : _filter.copyWith(employeeId: employeeId);
    _pageNumber = 1;
    load();
  }

  void setDateRange(JalaliDate? from, JalaliDate? to) {
    _filter = _filter.copyWith(
      fromDate: from,
      toDate: to,
      clearDates: from == null && to == null,
    );
    _pageNumber = 1;
    load();
  }

  void clearFilters() {
    _filter = AppointmentFilter(query: _filter.query);
    _pageNumber = 1;
    load();
  }

  void goToPage(int page) {
    _pageNumber = page.clamp(1, _page.totalPages == 0 ? 1 : _page.totalPages);
    load();
  }

  void setPageSize(int size) {
    _pageSize = size;
    _pageNumber = 1;
    load();
  }

  void toggleSort() {
    _ascending = !_ascending;
    load();
  }

  // ---------------------------------------------------------------------------
  // عملیات
  // ---------------------------------------------------------------------------

  /// بررسی تداخل زمانی پیش از ثبت.
  Future<Appointment?> checkConflict({
    required String employeeId,
    required DateTime startAt,
    required int durationMinutes,
    String? ignoreId,
  }) {
    return _repository.findConflict(
      employeeId: employeeId,
      startAt: startAt,
      durationMinutes: durationMinutes,
      ignoreId: ignoreId,
    );
  }

  Future<bool> create(Appointment appointment) async {
    _busy = true;
    notifyListeners();
    try {
      await _repository.create(appointment);
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> update(Appointment appointment) async {
    _busy = true;
    notifyListeners();
    try {
      await _repository.update(appointment);
      return true;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> changeStatus(Appointment appointment, AppointmentStatus status, {String? reason}) async {
    await _repository.changeStatus(appointment, status, reason: reason);
  }

  Future<void> reschedule(Appointment appointment, DateTime newStart) async {
    await _repository.reschedule(appointment, newStart);
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<List<Appointment>> forCustomer(String customerId) => _repository.fetchForCustomer(customerId);

  Future<List<Appointment>> forDay(DateTime day, {String? employeeId, String? serviceId}) =>
      _repository.fetchForDay(day, employeeId: employeeId, serviceId: serviceId);

  Future<Appointment?> byId(String id) => _repository.findById(id);

  /// یافتن همگام (برای فرم‌ها).
  Appointment? appointmentById(String id) => db.appointmentById(id);

  List<Appointment> get allAppointments => db.appointments;
}
