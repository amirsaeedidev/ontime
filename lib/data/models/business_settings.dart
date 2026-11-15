import 'employee.dart';

/// تنظیمات اتصال به پنل پیامک (فقط UI — اتصال واقعی انجام نمی‌شود).
enum SmsConnectionStatus {
  notConfigured('پیکربندی نشده'),
  testing('در حال بررسی'),
  connected('متصل'),
  failed('خطا در اتصال');

  const SmsConnectionStatus(this.label);
  final String label;
}

class SmsProviderSettings {
  const SmsProviderSettings({
    this.providerName = 'کاوه‌نگار',
    this.apiKey = '',
    this.username = '',
    this.password = '',
    this.senderNumber = '',
    this.endpoint = 'https://api.kavenegar.com/v1',
    this.isEnabled = false,
    this.status = SmsConnectionStatus.notConfigured,
    this.lastCheckedAt,
    this.credit = 150,
  });

  final String providerName;
  final String apiKey;
  final String username;
  final String password;
  final String senderNumber;
  final String endpoint;
  final bool isEnabled;
  final SmsConnectionStatus status;
  final DateTime? lastCheckedAt;
  final int credit;

  bool get isConfigured => apiKey.trim().isNotEmpty && senderNumber.trim().isNotEmpty;

  SmsProviderSettings copyWith({
    String? providerName,
    String? apiKey,
    String? username,
    String? password,
    String? senderNumber,
    String? endpoint,
    bool? isEnabled,
    SmsConnectionStatus? status,
    DateTime? lastCheckedAt,
    int? credit,
  }) {
    return SmsProviderSettings(
      providerName: providerName ?? this.providerName,
      apiKey: apiKey ?? this.apiKey,
      username: username ?? this.username,
      password: password ?? this.password,
      senderNumber: senderNumber ?? this.senderNumber,
      endpoint: endpoint ?? this.endpoint,
      isEnabled: isEnabled ?? this.isEnabled,
      status: status ?? this.status,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      credit: credit ?? this.credit,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider_name': providerName,
        'api_key': apiKey,
        'username': username,
        'password': password,
        'sender_number': senderNumber,
        'endpoint': endpoint,
        'is_enabled': isEnabled,
        'status': status.name,
        'last_checked_at': lastCheckedAt?.toIso8601String(),
        'credit': credit,
      };

  factory SmsProviderSettings.fromJson(Map<String, dynamic> json) => SmsProviderSettings(
        providerName: json['provider_name'] as String? ?? 'کاوه‌نگار',
        apiKey: json['api_key'] as String? ?? '',
        username: json['username'] as String? ?? '',
        password: json['password'] as String? ?? '',
        senderNumber: json['sender_number'] as String? ?? '',
        endpoint: json['endpoint'] as String? ?? '',
        isEnabled: json['is_enabled'] as bool? ?? false,
        status: SmsConnectionStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => SmsConnectionStatus.notConfigured,
        ),
        lastCheckedAt: json['last_checked_at'] == null ? null : DateTime.tryParse(json['last_checked_at'] as String),
        credit: (json['credit'] as num?)?.toInt() ?? 0,
      );
}

/// تنظیمات اطلاع‌رسانی پیامکی.
class NotificationSettings {
  const NotificationSettings({
    this.confirmationEnabled = true,
    this.reminderEnabled = true,
    this.cancellationEnabled = true,
    this.rescheduleEnabled = true,
    this.reminderHours = const [24, 2],
    this.sendToStaff = false,
  });

  final bool confirmationEnabled;
  final bool reminderEnabled;
  final bool cancellationEnabled;
  final bool rescheduleEnabled;
  final List<int> reminderHours;
  final bool sendToStaff;

  NotificationSettings copyWith({
    bool? confirmationEnabled,
    bool? reminderEnabled,
    bool? cancellationEnabled,
    bool? rescheduleEnabled,
    List<int>? reminderHours,
    bool? sendToStaff,
  }) {
    return NotificationSettings(
      confirmationEnabled: confirmationEnabled ?? this.confirmationEnabled,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      cancellationEnabled: cancellationEnabled ?? this.cancellationEnabled,
      rescheduleEnabled: rescheduleEnabled ?? this.rescheduleEnabled,
      reminderHours: reminderHours ?? this.reminderHours,
      sendToStaff: sendToStaff ?? this.sendToStaff,
    );
  }
}

/// قواعد رزرو، لغو و جابه‌جایی.
class BookingRules {
  const BookingRules({
    this.allowOnlineBooking = true,
    this.allowCustomerCancel = true,
    this.allowReschedule = true,
    this.maxReschedules = 1,
    this.minHoursBeforeChange = 2,
    this.maxAdvanceDays = 30,
    this.requireConfirmation = false,
    this.preventOverlap = true,
    this.slotIntervalMinutes = 15,
    this.cancelPenaltyCount = 3,
  });

  final bool allowOnlineBooking;
  final bool allowCustomerCancel;
  final bool allowReschedule;
  final int maxReschedules;
  final int minHoursBeforeChange;
  final int maxAdvanceDays;
  final bool requireConfirmation;
  final bool preventOverlap;
  final int slotIntervalMinutes;
  final int cancelPenaltyCount;

  BookingRules copyWith({
    bool? allowOnlineBooking,
    bool? allowCustomerCancel,
    bool? allowReschedule,
    int? maxReschedules,
    int? minHoursBeforeChange,
    int? maxAdvanceDays,
    bool? requireConfirmation,
    bool? preventOverlap,
    int? slotIntervalMinutes,
    int? cancelPenaltyCount,
  }) {
    return BookingRules(
      allowOnlineBooking: allowOnlineBooking ?? this.allowOnlineBooking,
      allowCustomerCancel: allowCustomerCancel ?? this.allowCustomerCancel,
      allowReschedule: allowReschedule ?? this.allowReschedule,
      maxReschedules: maxReschedules ?? this.maxReschedules,
      minHoursBeforeChange: minHoursBeforeChange ?? this.minHoursBeforeChange,
      maxAdvanceDays: maxAdvanceDays ?? this.maxAdvanceDays,
      requireConfirmation: requireConfirmation ?? this.requireConfirmation,
      preventOverlap: preventOverlap ?? this.preventOverlap,
      slotIntervalMinutes: slotIntervalMinutes ?? this.slotIntervalMinutes,
      cancelPenaltyCount: cancelPenaltyCount ?? this.cancelPenaltyCount,
    );
  }
}

/// تنظیمات هویت و اطلاعات مجموعه.
class BusinessSettings {
  const BusinessSettings({
    this.name = 'سالن زیبایی اُنتایم',
    this.slogan = 'مدیریت هوشمند نوبت‌ها',
    this.description = 'مجموعه تخصصی زیبایی و آرایش با تیمی از متخصصان حرفه‌ای.',
    this.phone = '02188776655',
    this.mobile = '09121234567',
    this.email = 'info@ontime.app',
    this.province = 'تهران',
    this.city = 'تهران',
    this.address = 'خیابان ولیعصر، بالاتر از پارک ساعی، پلاک ۱۲۴، طبقه ۳',
    this.postalCode = '1968913751',
    this.latitude = 35.7448,
    this.longitude = 51.4099,
    this.instagram = 'https://instagram.com/ontime.salon',
    this.telegram = 'https://t.me/ontimesalon',
    this.whatsapp = 'https://wa.me/989121234567',
    this.website = 'https://ontime.app',
    this.publicSlug = 'ontime-salon',
    this.currency = 'تومان',
    this.logoText = 'OT',
    this.workingHours = const {},
    this.holidays = const [],
    this.smsProvider = const SmsProviderSettings(),
    this.notifications = const NotificationSettings(),
    this.bookingRules = const BookingRules(),
    this.workSchedules = const {},
  });

  final String name;
  final String slogan;
  final String description;
  final String phone;
  final String mobile;
  final String email;
  final String province;
  final String city;
  final String address;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String instagram;
  final String telegram;
  final String whatsapp;
  final String website;
  final String publicSlug;
  final String currency;
  final String logoText;

  /// ساعات کاری مجموعه (کلید = روز هفته، ۰ = شنبه).
  final Map<int, List<Shift>> workingHours;

  /// تعطیلات هفتگی (روزهای هفته تعطیل).
  final List<int> holidays;

  /// شیفت‌های کاری قابل مدیریت (برای صفحه تنظیمات پیشرفته).
  final Map<int, List<Shift>> workSchedules;

  final SmsProviderSettings smsProvider;
  final NotificationSettings notifications;
  final BookingRules bookingRules;

  String get publicUrl => 'ontime.app/book/$publicSlug';
  String get fullUrl => 'https://ontime.app/book/$publicSlug';

  BusinessSettings copyWith({
    String? name,
    String? slogan,
    String? description,
    String? phone,
    String? mobile,
    String? email,
    String? province,
    String? city,
    String? address,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? instagram,
    String? telegram,
    String? whatsapp,
    String? website,
    String? publicSlug,
    String? currency,
    String? logoText,
    Map<int, List<Shift>>? workingHours,
    List<int>? holidays,
    Map<int, List<Shift>>? workSchedules,
    SmsProviderSettings? smsProvider,
    NotificationSettings? notifications,
    BookingRules? bookingRules,
  }) {
    return BusinessSettings(
      name: name ?? this.name,
      slogan: slogan ?? this.slogan,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      province: province ?? this.province,
      city: city ?? this.city,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      instagram: instagram ?? this.instagram,
      telegram: telegram ?? this.telegram,
      whatsapp: whatsapp ?? this.whatsapp,
      website: website ?? this.website,
      publicSlug: publicSlug ?? this.publicSlug,
      currency: currency ?? this.currency,
      logoText: logoText ?? this.logoText,
      workingHours: workingHours ?? this.workingHours,
      holidays: holidays ?? this.holidays,
      workSchedules: workSchedules ?? this.workSchedules,
      smsProvider: smsProvider ?? this.smsProvider,
      notifications: notifications ?? this.notifications,
      bookingRules: bookingRules ?? this.bookingRules,
    );
  }
}
