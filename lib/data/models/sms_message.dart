import 'enums.dart';

/// پیامک ارسال‌شده — جدول sms_messages.
class SmsMessage {
  const SmsMessage({
    required this.id,
    required this.recipientName,
    required this.phone,
    required this.templateKey,
    required this.templateLabel,
    required this.content,
    required this.status,
    required this.createdAt,
    this.sentAt,
    this.deliveredAt,
    this.error,
    this.appointmentId,
    this.cost = 1,
  });

  final String id;
  final String recipientName;
  final String phone;
  final String templateKey;
  final String templateLabel;
  final String content;
  final SmsStatus status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final String? error;
  final String? appointmentId;
  final int cost;

  SmsMessage copyWith({
    String? id,
    String? recipientName,
    String? phone,
    String? templateKey,
    String? templateLabel,
    String? content,
    SmsStatus? status,
    DateTime? createdAt,
    DateTime? sentAt,
    DateTime? deliveredAt,
    String? error,
    String? appointmentId,
    int? cost,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      templateKey: templateKey ?? this.templateKey,
      templateLabel: templateLabel ?? this.templateLabel,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      error: error ?? this.error,
      appointmentId: appointmentId ?? this.appointmentId,
      cost: cost ?? this.cost,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipient_name': recipientName,
        'phone': phone,
        'template_key': templateKey,
        'template_label': templateLabel,
        'content': content,
        'status': status.key,
        'created_at': createdAt.toUtc().toIso8601String(),
        'sent_at': sentAt?.toUtc().toIso8601String(),
        'delivered_at': deliveredAt?.toUtc().toIso8601String(),
        'error': error,
        'appointment_id': appointmentId,
        'cost': cost,
      };

  factory SmsMessage.fromJson(Map<String, dynamic> json) => SmsMessage(
        id: json['id'] as String,
        recipientName: json['recipient_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        templateKey: json['template_key'] as String? ?? 'custom',
        templateLabel: json['template_label'] as String? ?? 'پیامک',
        content: json['content'] as String? ?? '',
        status: SmsStatus.fromKey(json['status'] as String? ?? 'pending'),
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        sentAt: json['sent_at'] == null ? null : DateTime.tryParse(json['sent_at'] as String)?.toLocal(),
        deliveredAt: json['delivered_at'] == null ? null : DateTime.tryParse(json['delivered_at'] as String)?.toLocal(),
        error: json['error'] as String?,
        appointmentId: json['appointment_id'] as String?,
        cost: (json['cost'] as num?)?.toInt() ?? 1,
      );
}

/// قالب پیامک قابل ویرایش با متغیرهای پویا.
class SmsTemplate {
  const SmsTemplate({
    required this.key,
    required this.label,
    required this.body,
    this.isEnabled = true,
    this.hoursBefore,
  });

  final String key;
  final String label;
  final String body;
  final bool isEnabled;
  final int? hoursBefore;

  SmsTemplate copyWith({String? label, String? body, bool? isEnabled, int? hoursBefore}) => SmsTemplate(
        key: key,
        label: label ?? this.label,
        body: body ?? this.body,
        isEnabled: isEnabled ?? this.isEnabled,
        hoursBefore: hoursBefore ?? this.hoursBefore,
      );

  static const List<String> placeholders = [
    '{نام مشتری}',
    '{نام خدمت}',
    '{تاریخ نوبت}',
    '{ساعت نوبت}',
    '{نام متخصص}',
    '{کد پیگیری}',
    '{نام مجموعه}',
  ];
}

/// گزارش آماری پیامک‌ها.
class SmsStats {
  const SmsStats({
    required this.total,
    required this.delivered,
    required this.sent,
    required this.pending,
    required this.failed,
    required this.credit,
  });

  final int total;
  final int delivered;
  final int sent;
  final int pending;
  final int failed;
  final int credit;

  double get deliveryRate => total == 0 ? 0 : delivered / total * 100;

  double get failureRate => total == 0 ? 0 : failed / total * 100;
}
