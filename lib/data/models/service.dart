/// خدمت قابل ارائه — جدول services.
class Service {
  const Service({
    required this.id,
    required this.title,
    this.description = '',
    required this.price,
    required this.durationMinutes,
    this.bufferMinutes = 5,
    this.prepMinutes = 0,
    this.isActive = true,
    this.employeeIds = const [],
    this.category = 'عمومی',
    this.totalBookings = 0,
    this.maxPerDay,
    this.advanceDays = 30,
    this.requiresConfirmation = false,
    this.order = 0,
  });

  final String id;
  final String title;
  final String description;
  final num price;
  final int durationMinutes;

  /// زمان استراحت/آماده‌سازی بین دو نوبت.
  final int bufferMinutes;

  /// زمان آماده‌سازی قبل از شروع خدمت.
  final int prepMinutes;
  final bool isActive;
  final List<String> employeeIds;
  final String category;
  final int totalBookings;

  /// حداکثر تعداد رزرو این خدمت در یک روز.
  final int? maxPerDay;
  final int advanceDays;
  final bool requiresConfirmation;
  final int order;

  int get totalMinutes => prepMinutes + durationMinutes + bufferMinutes;

  Service copyWith({
    String? id,
    String? title,
    String? description,
    num? price,
    int? durationMinutes,
    int? bufferMinutes,
    int? prepMinutes,
    bool? isActive,
    List<String>? employeeIds,
    String? category,
    int? totalBookings,
    int? maxPerDay,
    int? advanceDays,
    bool? requiresConfirmation,
    int? order,
  }) {
    return Service(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      bufferMinutes: bufferMinutes ?? this.bufferMinutes,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      isActive: isActive ?? this.isActive,
      employeeIds: employeeIds ?? this.employeeIds,
      category: category ?? this.category,
      totalBookings: totalBookings ?? this.totalBookings,
      maxPerDay: maxPerDay ?? this.maxPerDay,
      advanceDays: advanceDays ?? this.advanceDays,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'duration_minutes': durationMinutes,
        'buffer_minutes': bufferMinutes,
        'prep_minutes': prepMinutes,
        'is_active': isActive,
        'employee_ids': employeeIds,
        'category': category,
        'total_bookings': totalBookings,
        'max_per_day': maxPerDay,
        'advance_days': advanceDays,
        'requires_confirmation': requiresConfirmation,
        'order': order,
      };

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: json['price'] as num? ?? 0,
        durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
        bufferMinutes: (json['buffer_minutes'] as num?)?.toInt() ?? 5,
        prepMinutes: (json['prep_minutes'] as num?)?.toInt() ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        employeeIds: (json['employee_ids'] as List?)?.cast<String>() ?? const [],
        category: json['category'] as String? ?? 'عمومی',
        totalBookings: (json['total_bookings'] as num?)?.toInt() ?? 0,
        maxPerDay: (json['max_per_day'] as num?)?.toInt(),
        advanceDays: (json['advance_days'] as num?)?.toInt() ?? 30,
        requiresConfirmation: json['requires_confirmation'] as bool? ?? false,
        order: (json['order'] as num?)?.toInt() ?? 0,
      );
}
