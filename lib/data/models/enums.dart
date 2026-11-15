import 'package:flutter/material.dart';

/// وضعیت نوبت با برچسب و رنگ فارسی.
enum AppointmentStatus {
  pending('در انتظار', Color(0xFF3B82F6)),
  confirmed('تأیید شده', Color(0xFF10B981)),
  completed('تکمیل شده', Color(0xFF22D3EE)),
  cancelled('لغو شده', Color(0xFFEF4444)),
  noShow('عدم حضور', Color(0xFFF59E0B));

  const AppointmentStatus(this.label, this.color);

  final String label;
  final Color color;

  String get key => name;

  static AppointmentStatus fromKey(String key) =>
      AppointmentStatus.values.firstWhere((s) => s.name == key, orElse: () => pending);

  bool get isActive => this == pending || this == confirmed;

  IconData get icon => switch (this) {
        AppointmentStatus.pending => Icons.hourglass_top_rounded,
        AppointmentStatus.confirmed => Icons.verified_rounded,
        AppointmentStatus.completed => Icons.check_circle_rounded,
        AppointmentStatus.cancelled => Icons.cancel_rounded,
        AppointmentStatus.noShow => Icons.person_off_rounded,
      };
}

/// وضعیت تحویل پیامک.
enum SmsStatus {
  pending('در صف ارسال', Color(0xFFF59E0B)),
  sent('ارسال شده', Color(0xFF3B82F6)),
  delivered('تحویل شده', Color(0xFF10B981)),
  failed('ناموفق', Color(0xFFEF4444));

  const SmsStatus(this.label, this.color);

  final String label;
  final Color color;

  String get key => name;

  static SmsStatus fromKey(String key) =>
      SmsStatus.values.firstWhere((s) => s.name == key, orElse: () => pending);
}

/// نوع رویداد در گزارش فعالیت‌ها.
enum ActivityType {
  appointmentCreated('ثبت نوبت', Icons.event_available_rounded, Color(0xFF3B82F6)),
  appointmentUpdated('ویرایش نوبت', Icons.edit_calendar_rounded, Color(0xFF8B5CF6)),
  appointmentCancelled('لغو نوبت', Icons.event_busy_rounded, Color(0xFFEF4444)),
  appointmentCompleted('تکمیل نوبت', Icons.task_alt_rounded, Color(0xFF10B981)),
  customerRegistered('ثبت مشتری', Icons.person_add_alt_rounded, Color(0xFF22D3EE)),
  serviceModified('تغییر خدمت', Icons.content_cut_rounded, Color(0xFFF59E0B)),
  employeeAdded('افزودن پرسنل', Icons.badge_rounded, Color(0xFF3B82F6)),
  smsSent('ارسال پیامک', Icons.sms_rounded, Color(0xFF10B981)),
  smsFailed('پیامک ناموفق', Icons.sms_failed_rounded, Color(0xFFEF4444)),
  settingsChanged('تغییر تنظیمات', Icons.settings_rounded, Color(0xFF94A3B8));

  const ActivityType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  String get key => name;

  static ActivityType fromKey(String key) =>
      ActivityType.values.firstWhere((s) => s.name == key, orElse: () => appointmentCreated);
}

/// نقش کاربری برای دسترسی‌ها.
enum StaffRole {
  owner('مدیر مجموعه'),
  manager('مدیر'),
  receptionist('پذیرش'),
  specialist('متخصص');

  const StaffRole(this.label);

  final String label;

  String get key => name;

  static StaffRole fromKey(String key) =>
      StaffRole.values.firstWhere((s) => s.name == key, orElse: () => specialist);
}

/// روزهای هفته بر اساس شروع هفته فارسی (شنبه).
class WeekDay {
  const WeekDay._();

  static const List<String> names = [
    'شنبه', 'یک‌شنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه',
  ];

  static const List<String> shortNames = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

  static String name(int index) => names[index % 7];
}
