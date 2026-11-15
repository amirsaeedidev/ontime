import '../../core/utils/jalali.dart';
import 'enums.dart';

/// نوبت — جدول appointments.
class Appointment {
  const Appointment({
    required this.id,
    required this.reference,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceIds,
    required this.serviceName,
    required this.employeeId,
    required this.employeeName,
    required this.startAt,
    required this.durationMinutes,
    this.status = AppointmentStatus.pending,
    this.note = '',
    this.price = 0,
    this.createdAt,
    this.updatedAt,
    this.rescheduleCount = 0,
    this.cancelReason,
    this.totalChanges = 0,
    this.createdBy = 'پذیرش',
  });

  final String id;
  final String reference;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<String> serviceIds;
  final String serviceName;
  final String employeeId;
  final String employeeName;
  final DateTime startAt;
  final int durationMinutes;
  final AppointmentStatus status;
  final String note;
  final num price;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int rescheduleCount;
  final String? cancelReason;
  final int totalChanges;
  final String createdBy;

  DateTime get endAt => startAt.add(Duration(minutes: durationMinutes));

  JalaliDate get jalali => JalaliDate.fromDateTime(startAt);

  int get startMinutes => startAt.hour * 60 + startAt.minute;
  int get endMinutes => startMinutes + durationMinutes;

  bool get isToday {
    final now = DateTime.now();
    return startAt.year == now.year && startAt.month == now.month && startAt.day == now.day;
  }

  bool get isUpcoming => status.isActive && startAt.isAfter(DateTime.now());

  bool get isPast => startAt.isBefore(DateTime.now());

  /// بررسی تداخل زمانی با نوبت دیگر برای یک متخصص.
  bool overlaps(DateTime otherStart, int otherDuration, {String? sameEmployeeId}) {
    if (sameEmployeeId != null && sameEmployeeId != employeeId) return false;
    if (status == AppointmentStatus.cancelled) return false;
    final otherEnd = otherStart.add(Duration(minutes: otherDuration));
    return startAt.isBefore(otherEnd) && otherStart.isBefore(endAt);
  }

  Appointment copyWith({
    String? id,
    String? reference,
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<String>? serviceIds,
    String? serviceName,
    String? employeeId,
    String? employeeName,
    DateTime? startAt,
    int? durationMinutes,
    AppointmentStatus? status,
    String? note,
    num? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? rescheduleCount,
    String? cancelReason,
    int? totalChanges,
    String? createdBy,
  }) {
    return Appointment(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceIds: serviceIds ?? this.serviceIds,
      serviceName: serviceName ?? this.serviceName,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      startAt: startAt ?? this.startAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      note: note ?? this.note,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rescheduleCount: rescheduleCount ?? this.rescheduleCount,
      cancelReason: cancelReason ?? this.cancelReason,
      totalChanges: totalChanges ?? this.totalChanges,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'service_ids': serviceIds,
        'service_name': serviceName,
        'employee_id': employeeId,
        'employee_name': employeeName,
        'start_at': startAt.toUtc().toIso8601String(),
        'duration_minutes': durationMinutes,
        'status': status.key,
        'note': note,
        'price': price,
        'created_at': createdAt?.toUtc().toIso8601String(),
        'updated_at': updatedAt?.toUtc().toIso8601String(),
        'reschedule_count': rescheduleCount,
        'cancel_reason': cancelReason,
        'total_changes': totalChanges,
        'created_by': createdBy,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        reference: json['reference'] as String? ?? '',
        customerId: json['customer_id'] as String? ?? '',
        customerName: json['customer_name'] as String? ?? '',
        customerPhone: json['customer_phone'] as String? ?? '',
        serviceIds: (json['service_ids'] as List?)?.cast<String>() ?? const [],
        serviceName: json['service_name'] as String? ?? '',
        employeeId: json['employee_id'] as String? ?? '',
        employeeName: json['employee_name'] as String? ?? '',
        startAt: DateTime.parse(json['start_at'] as String).toLocal(),
        durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
        status: AppointmentStatus.fromKey(json['status'] as String? ?? 'pending'),
        note: json['note'] as String? ?? '',
        price: json['price'] as num? ?? 0,
        createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null ? null : DateTime.tryParse(json['updated_at'] as String),
        rescheduleCount: (json['reschedule_count'] as num?)?.toInt() ?? 0,
        cancelReason: json['cancel_reason'] as String?,
        totalChanges: (json['total_changes'] as num?)?.toInt() ?? 0,
        createdBy: json['created_by'] as String? ?? 'پذیرش',
      );
}

/// فیلترهای صفحه نوبت‌ها.
class AppointmentFilter {
  const AppointmentFilter({
    this.query = '',
    this.status,
    this.serviceId,
    this.employeeId,
    this.fromDate,
    this.toDate,
  });

  final String query;
  final AppointmentStatus? status;
  final String? serviceId;
  final String? employeeId;
  final JalaliDate? fromDate;
  final JalaliDate? toDate;

  bool get isEmpty =>
      query.trim().isEmpty && status == null && serviceId == null && employeeId == null && fromDate == null && toDate == null;

  int get activeCount =>
      (status != null ? 1 : 0) + (serviceId != null ? 1 : 0) + (employeeId != null ? 1 : 0) + (fromDate != null || toDate != null ? 1 : 0);

  bool matches(Appointment a) {
    if (status != null && a.status != status) return false;
    if (serviceId != null && !a.serviceIds.contains(serviceId)) return false;
    if (employeeId != null && a.employeeId != employeeId) return false;
    final j = a.jalali;
    if (fromDate != null && j.isBefore(fromDate!)) return false;
    if (toDate != null && j.isAfter(toDate!)) return false;
    final q = query.trim();
    if (q.isNotEmpty) {
      final haystack = '${a.customerName} ${a.customerPhone} ${a.serviceName} ${a.employeeName} ${a.reference}';
      if (!haystack.contains(q)) return false;
    }
    return true;
  }

  AppointmentFilter copyWith({
    String? query,
    AppointmentStatus? status,
    String? serviceId,
    String? employeeId,
    JalaliDate? fromDate,
    JalaliDate? toDate,
    bool clearStatus = false,
    bool clearService = false,
    bool clearEmployee = false,
    bool clearDates = false,
  }) {
    return AppointmentFilter(
      query: query ?? this.query,
      status: clearStatus ? null : (status ?? this.status),
      serviceId: clearService ? null : (serviceId ?? this.serviceId),
      employeeId: clearEmployee ? null : (employeeId ?? this.employeeId),
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
    );
  }
}
