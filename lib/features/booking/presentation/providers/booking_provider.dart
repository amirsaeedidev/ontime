import 'package:flutter/foundation.dart';
import '../../../../core/providers/db_bound_provider.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../data/mock/app_database.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/customer.dart';
import '../../../../data/models/employee.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/service.dart';
import '../../../../data/repositories/appointment_repository.dart';
import '../../../../data/repositories/customer_repository.dart';
import '../../../../data/repositories/employee_repository.dart';
import '../../../../data/repositories/service_repository.dart';

/// خانه زمانی قابل انتخاب در صفحه رزرو عمومی.
class BookingSlot {
  const BookingSlot({required this.start, required this.isAvailable, this.reason});

  final DateTime start;
  final bool isAvailable;
  final String? reason;

  String get label =>
      '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
}

/// فرایند رزرو عمومی مشتری (بدون نیاز به نصب اپلیکیشن).
class BookingProvider extends DbBoundProvider {
  BookingProvider(
    this._appointments,
    this._services,
    this._employees,
    this._customers,
    AppDatabase db,
  ) : super(db) {
    _date = JalaliDate.today();
    loadServices();
  }

  final AppointmentRepository _appointments;
  final ServiceRepository _services;
  final EmployeeRepository _employees;
  final CustomerRepository _customers;

  int _step = 0;
  Service? _service;
  Employee? _employee;
  late JalaliDate _date;
  BookingSlot? _slot;
  String _name = '';
  String _phone = '';
  String _note = '';
  bool _submitting = false;
  Appointment? _created;
  String? _error;

  List<Service> _availableServices = const [];
  List<Employee> _availableEmployees = const [];
  List<BookingSlot> _slots = const [];
  bool _loading = true;
  String? _loadError;

  int get step => _step;
  Service? get service => _service;
  Employee? get employee => _employee;
  JalaliDate get date => _date;
  BookingSlot? get slot => _slot;
  String get name => _name;
  String get phone => _phone;
  String get note => _note;
  bool get submitting => _submitting;
  Appointment? get created => _created;
  String? get error => _error;
  List<Service> get availableServices => _availableServices;
  List<Employee> get availableEmployees => _availableEmployees;
  List<BookingSlot> get slots => _slots;
  bool get loading => _loading;
  String? get loadError => _loadError;
  int get totalSteps => 4;

  bool get canProceed {
    switch (_step) {
      case 0:
        return _service != null;
      case 1:
        return _employee != null;
      case 2:
        return _slot != null;
      case 3:
        return _name.trim().length >= 3 && _phone.trim().length >= 10;
      default:
        return false;
    }
  }

  Future<void> loadServices() async {
    _loading = true;
    notifyListeners();
    try {
      _availableServices = await _services.fetchServices(onlyActive: true);
    } catch (error) {
      _error = 'بارگذاری خدمات با خطا مواجه شد.';
      debugPrint('[ONTIME][Booking] services failed: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_step < 3) {
      _step++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_step > 0) {
      _step--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _step = step.clamp(0, 3);
    notifyListeners();
  }

  Future<void> selectService(Service service) async {
    _service = service;
    _employee = null;
    _slot = null;
    _availableEmployees = await _employees.fetchEmployees(serviceId: service.id);
    _availableEmployees = _availableEmployees.where((e) => e.isActive).toList();
    _step = 1;
    notifyListeners();
  }

  Future<void> selectEmployee(Employee employee) async {
    _employee = employee;
    _slot = null;
    await _loadSlots();
    _step = 2;
    notifyListeners();
  }

  void selectDate(JalaliDate date) {
    _date = date;
    _slot = null;
    _loadSlots();
    notifyListeners();
  }

  void selectSlot(BookingSlot slot) {
    if (!slot.isAvailable) return;
    _slot = slot;
    notifyListeners();
  }

  /// تاریخ‌های قابل انتخاب تا سقف مجاز رزرو.
  List<JalaliDate> get selectableDates {
    final maxDays = db.settings.bookingRules.maxAdvanceDays.clamp(7, 60);
    final today = JalaliDate.today();
    return [for (var i = 0; i < maxDays; i++) today.addDays(i)];
  }

  bool isDateEnabled(JalaliDate date) {
    if (db.settings.holidays.contains(date.weekday)) return false;
    if (_employee != null) {
      if (_employee!.daysOff.contains(date.iso)) return false;
      if (!_employee!.worksOn(date.weekday)) return false;
    }
    return true;
  }

  Future<void> _loadSlots() async {
    final service = _service;
    final employee = _employee;
    if (service == null || employee == null) {
      _slots = const [];
      return;
    }
    _loading = true;
    notifyListeners();
    final existing = await _appointments.fetchForDay(_date.toDateTime(), employeeId: employee.id);
    final shifts = employee.shiftsFor(_date.weekday);
    final interval = db.settings.bookingRules.slotIntervalMinutes.clamp(15, 60);
    final slots = <BookingSlot>[];
    for (final shift in shifts) {
      for (var minutes = shift.startMinutes; minutes + service.durationMinutes <= shift.endMinutes; minutes += interval) {
        final start = _date.toDateTime().add(Duration(minutes: minutes));
        if (start.isBefore(DateTime.now())) {
          slots.add(BookingSlot(start: start, isAvailable: false, reason: 'گذشته'));
          continue;
        }
        final conflict = existing.any((a) {
          if (a.status == AppointmentStatus.cancelled) return false;
          final end = start.add(Duration(minutes: service.durationMinutes + service.bufferMinutes));
          return a.startAt.isBefore(end) && start.isBefore(a.endAt);
        });
        slots.add(
          BookingSlot(
            start: start,
            isAvailable: !conflict,
            reason: conflict ? 'رزرو شده' : null,
          ),
        );
      }
    }
    _slots = slots;
    _loading = false;
    notifyListeners();
  }

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setNote(String value) {
    _note = value;
    notifyListeners();
  }

  /// ثبت نهایی رزرو (ساخت مشتری در صورت جدید بودن).
  Future<bool> submit() async {
    final service = _service;
    final employee = _employee;
    final slot = _slot;
    if (service == null || employee == null || slot == null) {
      _error = 'لطفاً همه مراحل را تکمیل کنید';
      notifyListeners();
      return false;
    }
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      final conflict = await _appointments.findConflict(
        employeeId: employee.id,
        startAt: slot.start,
        durationMinutes: service.totalMinutes,
      );
      if (conflict != null) {
        _error = 'این زمان هم‌اکنون رزرو شده است. لطفاً زمان دیگری انتخاب کنید.';
        _submitting = false;
        notifyListeners();
        return false;
      }

      var customer = db.customers.where((c) => c.phone == _phone).firstOrNull;
      if (customer == null) {
        customer = Customer(
          id: 'cus-${DateTime.now().millisecondsSinceEpoch}',
          fullName: _name.trim(),
          phone: _phone.trim(),
          createdAt: DateTime.now(),
          tags: const ['رزرو آنلاین'],
        );
        await _customers.create(customer);
      }

      final reference = 'OT-${1500 + db.appointments.length}';
      final appointment = Appointment(
        id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
        reference: reference,
        customerId: customer.id,
        customerName: customer.fullName,
        customerPhone: customer.phone,
        serviceIds: [service.id],
        serviceName: service.title,
        employeeId: employee.id,
        employeeName: employee.fullName,
        startAt: slot.start,
        durationMinutes: service.durationMinutes,
        status: db.settings.bookingRules.requireConfirmation ? AppointmentStatus.pending : AppointmentStatus.confirmed,
        price: service.price,
        note: _note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'صفحه رزرو آنلاین',
      );
      await _appointments.create(appointment);
      _created = appointment;
      _submitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'خطا در ثبت نوبت. لطفاً دوباره تلاش کنید.';
      _submitting = false;
      notifyListeners();
      return false;
    }
  }

  /// بازنشانی فرایند برای رزرو جدید.
  void reset() {
    _step = 0;
    _service = null;
    _employee = null;
    _slot = null;
    _name = '';
    _phone = '';
    _note = '';
    _created = null;
    _error = null;
    _date = JalaliDate.today();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // مدیریت نوبت توسط مشتری (لغو / جابه‌جایی)
  // ---------------------------------------------------------------------------

  /// آیا مشتری می‌تواند این نوبت را لغو کند؟
  String? cancelBlockReason(Appointment appointment) {
    final rules = db.settings.bookingRules;
    if (!rules.allowCustomerCancel) return 'لغو نوبت توسط مشتری غیرفعال است.';
    final hours = appointment.startAt.difference(DateTime.now()).inHours;
    if (hours < rules.minHoursBeforeChange) {
      return 'تا شروع نوبت کمتر از ${rules.minHoursBeforeChange} ساعت باقی مانده است.';
    }
    return null;
  }

  /// آیا مشتری می‌تواند این نوبت را جابه‌جا کند؟
  String? rescheduleBlockReason(Appointment appointment) {
    final rules = db.settings.bookingRules;
    if (!rules.allowReschedule) return 'جابه‌جایی نوبت غیرفعال است.';
    if (appointment.rescheduleCount >= rules.maxReschedules) {
      return 'سقف جابه‌جایی (${rules.maxReschedules} بار) تکمیل شده است.';
    }
    final hours = appointment.startAt.difference(DateTime.now()).inHours;
    if (hours < rules.minHoursBeforeChange) {
      return 'تا شروع نوبت کمتر از ${rules.minHoursBeforeChange} ساعت باقی مانده است.';
    }
    return null;
  }

  Future<void> customerCancel(Appointment appointment, {String reason = 'لغو توسط مشتری'}) async {
    await _appointments.changeStatus(appointment, AppointmentStatus.cancelled, reason: reason);
    notifyListeners();
  }

  Future<bool> customerReschedule(Appointment appointment, DateTime newStart) async {
    final conflict = await _appointments.findConflict(
      employeeId: appointment.employeeId,
      startAt: newStart,
      durationMinutes: appointment.durationMinutes,
      ignoreId: appointment.id,
    );
    if (conflict != null) {
      _error = 'این زمان قبلاً رزرو شده است.';
      notifyListeners();
      return false;
    }
    await _appointments.reschedule(appointment, newStart, byCustomer: true);
    notifyListeners();
    return true;
  }

  /// یافتن نوبت‌های مشتری با شماره موبایل.
  Future<List<Appointment>> lookup(String phone) async {
    final normalized = phone.trim();
    final customer = db.customers.where((c) => c.phone == normalized).firstOrNull;
    if (customer == null) return const [];
    return _appointments.fetchForCustomer(customer.id);
  }

  Future<List<Appointment>> lookupByReference(String reference) async {
    final appointment = db.appointments.where((a) => a.reference == reference.trim()).firstOrNull;
    return appointment == null ? const [] : [appointment];
  }
}
