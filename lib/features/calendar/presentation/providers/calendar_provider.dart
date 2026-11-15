import 'package:flutter/foundation.dart';
import '../../../../core/providers/db_bound_provider.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../data/mock/app_database.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/employee.dart';
import '../../../../data/models/service.dart';
import '../../../../data/repositories/appointment_repository.dart';
import '../../../../data/repositories/employee_repository.dart';
import '../../../../data/repositories/service_repository.dart';

/// حالت نمایش تقویم.
enum CalendarView { daily, weekly, monthly }

/// مدیریت تقویم شمسی (روز/هفته/ماه)، فیلترها و خانه‌های زمانی.
class CalendarProvider extends DbBoundProvider {
  CalendarProvider(
    this._appointments,
    this._employees,
    this._services,
    AppDatabase db,
  ) : super(db) {
    _today = JalaliDate.today();
    _anchor = _today;
    _selected = _today;
    load();
  }

  final AppointmentRepository _appointments;
  final EmployeeRepository _employees;
  final ServiceRepository _services;

  late JalaliDate _today;
  late JalaliDate _anchor;
  late JalaliDate _selected;
  CalendarView _view = CalendarView.monthly;
  String? _employeeId;
  String? _serviceId;
  bool _loading = true;
  String? _loadError;
  List<Appointment> _rangeAppointments = const [];
  List<Employee> _employeeList = const [];
  List<Service> _serviceList = const [];

  JalaliDate get today => _today;
  JalaliDate get anchor => _anchor;
  JalaliDate get selected => _selected;
  CalendarView get view => _view;
  String? get employeeId => _employeeId;
  String? get serviceId => _serviceId;
  bool get loading => _loading;
  String? get loadError => _loadError;
  List<Employee> get employees => _employeeList;
  List<Service> get services => _serviceList;
  List<Appointment> get appointments => _rangeAppointments;

  void setView(CalendarView view) {
    _view = view;
    notifyListeners();
  }

  void setSelected(JalaliDate date) {
    _selected = date;
    _anchor = date;
    notifyListeners();
  }

  void selectToday() {
    _today = JalaliDate.today();
    _selected = _today;
    _anchor = _today;
    notifyListeners();
  }

  void setEmployee(String? id) {
    _employeeId = id;
    load();
  }

  void setService(String? id) {
    _serviceId = id;
    load();
  }

  void next() {
    switch (_view) {
      case CalendarView.daily:
        _anchor = _anchor.addDays(1);
        _selected = _anchor;
      case CalendarView.weekly:
        _anchor = _anchor.addDays(7);
      case CalendarView.monthly:
        _anchor = _anchor.addMonths(1);
    }
    notifyListeners();
  }

  void previous() {
    switch (_view) {
      case CalendarView.daily:
        _anchor = _anchor.addDays(-1);
        _selected = _anchor;
      case CalendarView.weekly:
        _anchor = _anchor.addDays(-7);
      case CalendarView.monthly:
        _anchor = _anchor.addMonths(-1);
    }
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _employeeList = await _employees.fetchEmployees();
      _serviceList = await _services.fetchServices();
      _rangeAppointments = await _appointments.fetchAll();
    } catch (error) {
      _loadError = '$error';
      debugPrint('[ONTIME][Calendar] load failed: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void onDatabaseChanged() {
    _rangeAppointments = db.appointments;
    _employeeList = db.employees;
    _serviceList = db.services;
    notifyListeners();
  }

  /// همه نوبت‌های یک روز (با اعمال فیلترها).
  List<Appointment> appointmentsOn(JalaliDate date) {
    return _rangeAppointments.where((a) {
      if (!a.jalali.sameDay(date)) return false;
      if (_employeeId != null && a.employeeId != _employeeId) return false;
      if (_serviceId != null && !a.serviceIds.contains(_serviceId)) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
  }

  /// روزهای هفته جاری (شنبه تا جمعه) برای نمای هفتگی.
  List<JalaliDate> get weekDays {
    final start = _anchor.addDays(-_anchor.weekday);
    return [for (var i = 0; i < 7; i++) start.addDays(i)];
  }

  /// جدول ماه شمسی: ۴۲ خانه (۶ هفته) با خانه‌های ماه قبل/بعد.
  List<CalendarCell> monthGrid(JalaliDate month) {
    final first = JalaliDate(month.year, month.month, 1);
    final leading = first.weekday;
    final daysInMonth = first.monthLength;
    final prevMonth = JalaliDate(month.year, month.month, 1).addMonths(-1);
    final prevDays = prevMonth.monthLength;
    final cells = <CalendarCell>[];
    for (var i = leading - 1; i >= 0; i--) {
      cells.add(CalendarCell(
        date: JalaliDate(prevMonth.year, prevMonth.month, prevDays - i),
        isCurrentMonth: false,
      ));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(CalendarCell(date: JalaliDate(first.year, first.month, d), isCurrentMonth: true));
    }
    var next = JalaliDate(month.year, month.month, 1).addMonths(1);
    var i = 1;
    while (cells.length < 42) {
      cells.add(CalendarCell(date: JalaliDate(next.year, next.month, i), isCurrentMonth: false));
      i++;
    }
    return cells;
  }

  /// خانه‌های زمانی یک روز بر اساس ساعات کاری و نوبت‌های ثبت‌شده.
  List<TimeSlot> slotsFor(JalaliDate date, {int intervalMinutes = 30, String? employee}) {
    final dayAppointments = appointmentsOn(date)
        .where((a) => employee == null || a.employeeId == employee)
        .toList();
    final slots = <TimeSlot>[];
    for (var minutes = 9 * 60; minutes <= 19 * 60; minutes += intervalMinutes) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      final start = date.toDateTime().add(Duration(hours: hour, minutes: minute));
      final busy = dayAppointments.where((a) {
        return !start.isBefore(a.startAt) && start.isBefore(a.endAt);
      }).toList();
      slots.add(
        TimeSlot(
          hour: hour,
          minute: minute,
          appointment: busy.isEmpty ? null : busy.first,
          isPast: date.sameDay(today) && DateTime.now().isAfter(start),
        ),
      );
    }
    return slots;
  }

  /// آیا روز تعطیل است؟
  bool isHoliday(JalaliDate date) => date.weekday == 6 || db.settings.holidays.contains(date.weekday);

  int get monthlyAppointmentsCount => _rangeAppointments
      .where((a) => a.jalali.month == _anchor.month && a.jalali.year == _anchor.year)
      .length;
}

/// یک خانه از جدول ماه.
class CalendarCell {
  const CalendarCell({required this.date, required this.isCurrentMonth});

  final JalaliDate date;
  final bool isCurrentMonth;
}

/// یک خانه زمانی در نمای روزانه.
class TimeSlot {
  const TimeSlot({
    required this.hour,
    required this.minute,
    this.appointment,
    this.isPast = false,
  });

  final int hour;
  final int minute;
  final Appointment? appointment;
  final bool isPast;

  bool get isBooked => appointment != null;
  String get label => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
