import '../../core/models/page_result.dart';
import '../mock/app_database.dart';
import '../models/business_settings.dart';
import '../models/enums.dart';
import '../models/sms_message.dart';

abstract class SmsRepository {
  Future<PageResult<SmsMessage>> fetchMessages({
    String query = '',
    SmsStatus? status,
    int page = 1,
    int pageSize = 8,
  });

  Future<SmsStats> fetchStats();

  Future<List<SmsTemplate>> fetchTemplates();

  Future<SmsProviderSettings> fetchProviderSettings();

  Future<void> updateTemplate(SmsTemplate template);

  Future<void> updateProviderSettings(SmsProviderSettings settings);

  /// شبیه‌سازی ارسال پیامک (بدون اتصال به پنل واقعی).
  Future<SmsMessage> sendMock({
    required String recipientName,
    required String phone,
    required String templateKey,
    required String templateLabel,
    required String content,
  });

  Future<SmsConnectionStatus> testConnection(SmsProviderSettings settings);

  Future<void> updateNotifications(NotificationSettings notifications);
}

class MockSmsRepository implements SmsRepository {
  MockSmsRepository(this._db);

  final AppDatabase _db;

  @override
  Future<PageResult<SmsMessage>> fetchMessages({
    String query = '',
    SmsStatus? status,
    int page = 1,
    int pageSize = 8,
  }) async {
    await _db.delay(150);
    final q = query.trim();
    final filtered = _db.smsMessages.where((m) {
      if (status != null && m.status != status) return false;
      if (q.isEmpty) return true;
      return m.recipientName.contains(q) || m.phone.contains(q) || m.content.contains(q);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final start = (page - 1) * pageSize;
    if (start >= filtered.length) {
      return PageResult(items: const [], total: filtered.length, page: page, pageSize: pageSize);
    }
    final end = (start + pageSize).clamp(0, filtered.length);
    return PageResult(items: filtered.sublist(start, end), total: filtered.length, page: page, pageSize: pageSize);
  }

  @override
  Future<SmsStats> fetchStats() async {
    final list = _db.smsMessages;
    return SmsStats(
      total: list.length,
      delivered: list.where((m) => m.status == SmsStatus.delivered).length,
      sent: list.where((m) => m.status == SmsStatus.sent).length,
      pending: list.where((m) => m.status == SmsStatus.pending).length,
      failed: list.where((m) => m.status == SmsStatus.failed).length,
      credit: _db.settings.smsProvider.credit,
    );
  }

  @override
  Future<List<SmsTemplate>> fetchTemplates() async => _db.smsTemplates;

  @override
  Future<SmsProviderSettings> fetchProviderSettings() async => _db.settings.smsProvider;

  @override
  Future<void> updateTemplate(SmsTemplate template) async {
    await _db.delay(140);
    _db.updateTemplate(template);
  }

  @override
  Future<void> updateProviderSettings(SmsProviderSettings settings) async {
    await _db.delay(200);
    _db.updateSettings(
      _db.settings.copyWith(smsProvider: settings),
      logTitle: 'به‌روزرسانی تنظیمات پیامک',
      logDescription: 'تنظیمات پنل پیامک ${settings.providerName} ذخیره شد.',
    );
  }

  @override
  Future<SmsMessage> sendMock({
    required String recipientName,
    required String phone,
    required String templateKey,
    required String templateLabel,
    required String content,
  }) async {
    await _db.delay(320);
    final message = SmsMessage(
      id: _db.nextId('sms'),
      recipientName: recipientName,
      phone: phone,
      templateKey: templateKey,
      templateLabel: templateLabel,
      content: content,
      status: SmsStatus.delivered,
      createdAt: DateTime.now(),
      sentAt: DateTime.now(),
      deliveredAt: DateTime.now().add(const Duration(seconds: 12)),
    );
    _db.addSms(message);
    return message;
  }

  @override
  Future<void> updateNotifications(NotificationSettings notifications) async {
    await _db.delay(160);
    _db.updateSettings(
      _db.settings.copyWith(notifications: notifications),
      logTitle: 'تغییر تنظیمات اطلاع‌رسانی',
      logDescription: 'تنظیمات پیامک‌های خودکار به‌روزرسانی شد.',
    );
  }

  @override
  Future<SmsConnectionStatus> testConnection(SmsProviderSettings settings) async {
    await _db.delay(700);
    return settings.apiKey.trim().length >= 12 && settings.senderNumber.trim().isNotEmpty
        ? SmsConnectionStatus.connected
        : SmsConnectionStatus.failed;
  }
}
