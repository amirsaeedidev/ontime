import 'enums.dart';

/// یک شیفت کاری در طول روز.
class Shift {
  const Shift({required this.start, required this.end});

  /// قالب «HH:mm» با ارقام لاتین برای ذخیره‌سازی.
  final String start;
  final String end;

  int get startMinutes => _toMinutes(start);
  int get endMinutes => _toMinutes(end);

  static int _toMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  String get label => '${_fa(start)} تا ${_fa(end)}';

  static String _fa(String v) {
    final parts = v.split(':');
    if (parts.length != 2) return v;
    return '${_digits(parts[0])}:${_digits(parts[1])}';
  }

  static String _digits(String v) {
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    return v.split('').map((c) => int.tryParse(c) != null ? fa[int.parse(c)] : c).join();
  }

  Shift copyWith({String? start, String? end}) => Shift(start: start ?? this.start, end: end ?? this.end);

  Map<String, dynamic> toJson() => {'start': start, 'end': end};

  factory Shift.fromJson(Map<String, dynamic> json) =>
      Shift(start: json['start'] as String? ?? '09:00', end: json['end'] as String? ?? '17:00');
}

/// پرسنل / متخصص — جدول employees.
class Employee {
  const Employee({
    required this.id,
    required this.fullName,
    required this.phone,
    this.title = '',
    this.role = StaffRole.specialist,
    this.isActive = true,
    this.serviceIds = const [],
    this.schedule = const {},
    this.daysOff = const [],
    this.permissions = const [],
    this.colorValue = 0xFF2563EB,
    this.email = '',
    this.startedAt,
    this.bookedCount = 0,
    this.rating = 4.8,
  });

  final String id;
  final String fullName;
  final String phone;
  final String title;
  final StaffRole role;
  final bool isActive;
  final List<String> serviceIds;

  /// نقشه ساعت کاری: کلید = روز هفته (۰ = شنبه).
  final Map<int, List<Shift>> schedule;

  /// روزهای تعطیل خاص (ISO شمسی yyyy-MM-dd).
  final List<String> daysOff;
  final List<String> permissions;
  final int colorValue;
  final String email;
  final DateTime? startedAt;
  final int bookedCount;
  final double rating;

  List<Shift> shiftsFor(int weekday) => schedule[weekday] ?? const [];

  bool worksOn(int weekday) => shiftsFor(weekday).isNotEmpty;

  String get initials => fullName.trim().isEmpty ? '؟' : fullName.trim().split(RegExp(r'\s+')).first.characters.first;

  Employee copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? title,
    StaffRole? role,
    bool? isActive,
    List<String>? serviceIds,
    Map<int, List<Shift>>? schedule,
    List<String>? daysOff,
    List<String>? permissions,
    int? colorValue,
    String? email,
    DateTime? startedAt,
    int? bookedCount,
    double? rating,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      title: title ?? this.title,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      serviceIds: serviceIds ?? this.serviceIds,
      schedule: schedule ?? this.schedule,
      daysOff: daysOff ?? this.daysOff,
      permissions: permissions ?? this.permissions,
      colorValue: colorValue ?? this.colorValue,
      email: email ?? this.email,
      startedAt: startedAt ?? this.startedAt,
      bookedCount: bookedCount ?? this.bookedCount,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'phone': phone,
        'title': title,
        'role': role.key,
        'is_active': isActive,
        'service_ids': serviceIds,
        'schedule': schedule.map((k, v) => MapEntry(k.toString(), v.map((s) => s.toJson()).toList())),
        'days_off': daysOff,
        'permissions': permissions,
        'color_value': colorValue,
        'email': email,
        'started_at': startedAt?.toIso8601String(),
        'booked_count': bookedCount,
        'rating': rating,
      };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as String,
        fullName: json['full_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        title: json['title'] as String? ?? '',
        role: StaffRole.fromKey(json['role'] as String? ?? 'specialist'),
        isActive: json['is_active'] as bool? ?? true,
        serviceIds: (json['service_ids'] as List?)?.cast<String>() ?? const [],
        schedule: ((json['schedule'] as Map?) ?? {}).map(
          (k, v) => MapEntry(
            int.parse(k.toString()),
            (v as List).map((e) => Shift.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
          ),
        ),
        daysOff: (json['days_off'] as List?)?.cast<String>() ?? const [],
        permissions: (json['permissions'] as List?)?.cast<String>() ?? const [],
        colorValue: (json['color_value'] as num?)?.toInt() ?? 0xFF2563EB,
        email: json['email'] as String? ?? '',
        startedAt: json['started_at'] == null ? null : DateTime.tryParse(json['started_at'] as String),
        bookedCount: (json['booked_count'] as num?)?.toInt() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      );
}

extension _Chars on String {
  Iterable<String> get characters => runes.map(String.fromCharCode);
}
