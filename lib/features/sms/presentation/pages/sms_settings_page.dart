import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/business_settings.dart';
import '../providers/sms_provider.dart';

/// تنظیمات پنل پیامک (بدون اتصال واقعی در این فاز).
class SmsSettingsPage extends StatefulWidget {
  const SmsSettingsPage({super.key});

  @override
  State<SmsSettingsPage> createState() => _SmsSettingsPageState();
}

class _SmsSettingsPageState extends State<SmsSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiKey = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _sender = TextEditingController();
  final _endpoint = TextEditingController();
  final _testPhone = TextEditingController(text: '09121234567');

  String _providerName = 'کاوه‌نگار';
  bool _enabled = false;
  bool _maskKey = true;
  bool _maskPassword = true;
  bool _prefilled = false;
  SmsConnectionStatus _status = SmsConnectionStatus.notConfigured;

  static const _providers = ['کاوه‌نگار', 'ملی‌پیامک', 'فراز اس‌ام‌اس', 'پنل اختصاصی (وب‌سرویس)'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final settings = context.read<SmsProvider>().provider;
    _providerName = settings.providerName;
    _apiKey.text = settings.apiKey;
    _username.text = settings.username;
    _password.text = settings.password;
    _sender.text = settings.senderNumber;
    _endpoint.text = settings.endpoint;
    _enabled = settings.isEnabled;
    _status = settings.status;
  }

  @override
  void dispose() {
    _apiKey.dispose();
    _username.dispose();
    _password.dispose();
    _sender.dispose();
    _endpoint.dispose();
    _testPhone.dispose();
    super.dispose();
  }

  SmsProviderSettings get _current => SmsProviderSettings(
        providerName: _providerName,
        apiKey: _apiKey.text.trim(),
        username: _username.text.trim(),
        password: _password.text.trim(),
        senderNumber: _sender.text.trim(),
        endpoint: _endpoint.text.trim(),
        isEnabled: _enabled,
        status: _status,
        credit: 150,
      );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmsProvider>();
    final pal = context.pal;
    final statusColor = switch (_status) {
      SmsConnectionStatus.connected => pal.success,
      SmsConnectionStatus.failed => pal.danger,
      SmsConnectionStatus.testing => pal.warning,
      SmsConnectionStatus.notConfigured => pal.textMuted,
    };

    return PageScaffold(
      title: 'تنظیمات پنل پیامک',
      subtitle: 'پیکربندی ارائه‌دهنده و اعتبارسنجی اتصال',
      icon: Icons.settings_suggest_rounded,
      showBackButton: true,
      actions: [
        SoftButton(label: 'قالب پیامک‌ها', icon: Icons.article_outlined, onTap: () => context.push('/sms/templates')),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              gradient: LinearGradient(
                colors: [statusColor.withValues(alpha: 0.2), pal.surface],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderColor: statusColor.withValues(alpha: 0.4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconTile(icon: Icons.sms_rounded, color: statusColor, size: 40, radius: 12),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.provider.providerName,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: pal.textPrimary),
                            ),
                            Text(
                              'اعتبار باقیمانده: ${FaNum.ofInt(provider.provider.credit)} پیامک',
                              style: TextStyle(fontSize: 10.5, color: pal.textMuted),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(label: _status.label, color: statusColor, dense: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppSwitchRow(
                    title: 'سرویس پیامک فعال باشد',
                    description: 'ارسال خودکار پیامک تأیید و یادآوری پس از فعال‌سازی انجام می‌شود.',
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                    icon: Icons.power_settings_new_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'اطلاعات ارائه‌دهنده'),
                  const SizedBox(height: 14),
                  AppDropdown<String>(
                    label: 'ارائه‌دهنده پیامک',
                    items: _providers,
                    value: _providerName,
                    onChanged: (v) => setState(() => _providerName = v ?? _providerName),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _apiKey,
                    label: 'کلید API',
                    hint: 'کلید دسترسی پنل',
                    icon: Icons.vpn_key_outlined,
                    obscure: _maskKey,
                    validator: (v) => Validators.required(v, label: 'کلید API'),
                    suffix: IconButton(
                      icon: Icon(_maskKey ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          size: 17, color: pal.textMuted),
                      onPressed: () => setState(() => _maskKey = !_maskKey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _username,
                          label: 'نام کاربری',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => Validators.username(v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: _password,
                          label: 'رمز عبور',
                          icon: Icons.lock_outline_rounded,
                          obscure: _maskPassword,
                          suffix: IconButton(
                            icon: Icon(_maskPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                size: 17, color: pal.textMuted),
                            onPressed: () => setState(() => _maskPassword = !_maskPassword),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _sender,
                          label: 'شماره فرستنده',
                          hint: '10004341',
                          icon: Icons.numbers_rounded,
                          numericFa: true,
                          validator: (v) => Validators.required(v, label: 'شماره فرستنده'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: _endpoint,
                          label: 'آدرس سرویس (Endpoint)',
                          hint: 'https://api.example.com/v1',
                          icon: Icons.link_rounded,
                          validator: (v) => Validators.required(v, label: 'آدرس سرویس'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SolidButton(
                        label: 'ذخیره تنظیمات',
                        icon: Icons.save_rounded,
                        height: 46,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          await provider.saveProvider(_current);
                          if (context.mounted) AppToast.show(context, 'تنظیمات پیامک ذخیره شد');
                        },
                      ),
                      SolidButton(
                        label: provider.testing ? 'در حال بررسی...' : 'تست اتصال',
                        icon: Icons.wifi_tethering_rounded,
                        height: 46,
                        outlined: true,
                        loading: provider.testing,
                        onPressed: () async {
                          setState(() => _status = SmsConnectionStatus.testing);
                          final result = await provider.testConnection(_current);
                          if (!context.mounted) return;
                          setState(() => _status = result);
                          AppToast.show(
                            context,
                            result == SmsConnectionStatus.connected
                                ? 'اتصال با موفقیت برقرار شد (شبیه‌سازی)'
                                : 'اتصال ناموفق بود؛ کلید API یا شماره فرستنده را بررسی کنید',
                            success: result == SmsConnectionStatus.connected,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'کلید API و رمز عبور به‌صورت پوشیده نمایش داده می‌شوند. در این فاز هیچ اتصال واقعی برقرار نمی‌شود.',
                    style: TextStyle(fontSize: 10, color: pal.textMuted, height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'ارسال پیامک آزمایشی'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _testPhone,
                          label: 'شماره گیرنده',
                          icon: Icons.call_outlined,
                          keyboardType: TextInputType.phone,
                          numericFa: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SolidButton(
                        label: 'ارسال تست',
                        icon: Icons.send_rounded,
                        height: 48,
                        loading: provider.sendingTest,
                        onPressed: () async {
                          final message = await provider.sendTest(
                            phone: _testPhone.text.trim(),
                            recipient: 'کاربر آزمایشی',
                          );
                          if (context.mounted) {
                            AppToast.show(context, 'پیامک آزمایشی ثبت شد (${message.status.label})');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
