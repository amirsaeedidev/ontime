import 'package:flutter/foundation.dart';
import '../../../../core/models/page_result.dart';
import '../../../../core/providers/db_bound_provider.dart';
import '../../../../data/mock/app_database.dart';
import '../../../../data/models/business_settings.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/sms_message.dart';
import '../../../../data/repositories/sms_repository.dart';

/// مانیتورینگ پیامک، قالب‌ها و تنظیمات پنل.
class SmsProvider extends DbBoundProvider {
  SmsProvider(this._repository, AppDatabase db) : super(db) {
    load();
  }

  final SmsRepository _repository;

  PageResult<SmsMessage> _page = PageResult.empty(pageSize: 8);
  SmsStats? _stats;
  List<SmsTemplate> _templates = const [];
  SmsProviderSettings _provider = const SmsProviderSettings();
  String _query = '';
  SmsStatus? _statusFilter;
  int _pageNumber = 1;
  bool _loading = true;
  String? _loadError;
  bool _testing = false;
  bool _sendingTest = false;

  PageResult<SmsMessage> get page => _page;
  List<SmsMessage> get messages => _page.items;
  SmsStats? get stats => _stats;
  List<SmsTemplate> get templates => _templates;
  SmsProviderSettings get provider => _provider;
  String get query => _query;
  SmsStatus? get statusFilter => _statusFilter;
  int get pageNumber => _pageNumber;
  bool get loading => _loading;
  String? get loadError => _loadError;
  bool get testing => _testing;
  bool get sendingTest => _sendingTest;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _page = await _repository.fetchMessages(query: _query, status: _statusFilter, page: _pageNumber, pageSize: 8);
      _stats = await _repository.fetchStats();
      _templates = await _repository.fetchTemplates();
      _provider = await _repository.fetchProviderSettings();
    } catch (error) {
      _loadError = '$error';
      debugPrint('[ONTIME][Sms] load failed: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void onDatabaseChanged() {
    _refresh();
  }

  Future<void> _refresh() async {
    _page = await _repository.fetchMessages(query: _query, status: _statusFilter, page: _pageNumber, pageSize: 8);
    _stats = await _repository.fetchStats();
    _templates = await _repository.fetchTemplates();
    _provider = db.settings.smsProvider;
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    _pageNumber = 1;
    load();
  }

  void filterStatus(SmsStatus? status) {
    _statusFilter = status;
    _pageNumber = 1;
    load();
  }

  void goToPage(int page) {
    _pageNumber = page.clamp(1, _page.totalPages == 0 ? 1 : _page.totalPages);
    load();
  }

  NotificationSettings get dbSettingsNotifications => db.settings.notifications;

  Future<void> saveNotifications(NotificationSettings settings) async {
    await _repository.updateNotifications(settings);
    notifyListeners();
  }

  Future<void> saveTemplate(SmsTemplate template) async {
    await _repository.updateTemplate(template);
  }

  Future<void> saveProvider(SmsProviderSettings settings) async {
    await _repository.updateProviderSettings(settings);
    _provider = db.settings.smsProvider;
    notifyListeners();
  }

  Future<SmsConnectionStatus> testConnection(SmsProviderSettings settings) async {
    _testing = true;
    notifyListeners();
    try {
      final status = await _repository.testConnection(settings);
      _provider = settings.copyWith(status: status, lastCheckedAt: DateTime.now());
      await _repository.updateProviderSettings(_provider);
      return status;
    } finally {
      _testing = false;
      notifyListeners();
    }
  }

  Future<SmsMessage> sendTest({required String phone, required String recipient, String? content}) async {
    _sendingTest = true;
    notifyListeners();
    try {
      return await _repository.sendMock(
        recipientName: recipient,
        phone: phone,
        templateKey: 'test',
        templateLabel: 'پیامک آزمایشی',
        content: content ?? 'این یک پیامک آزمایشی از سامانه ${db.settings.name} است.',
      );
    } finally {
      _sendingTest = false;
      notifyListeners();
    }
  }

  /// ارسال پیامک تأیید برای یک نوبت (شبیه‌سازی).
  Future<SmsMessage> sendConfirmation({
    required String recipient,
    required String phone,
    required String content,
    required String appointmentId,
  }) async {
    return _repository.sendMock(
      recipientName: recipient,
      phone: phone,
      templateKey: 'confirmation',
      templateLabel: 'تأیید نوبت',
      content: content,
    );
  }
}
