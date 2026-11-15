import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../sms/presentation/providers/sms_provider.dart';

/// تنظیمات اطلاع‌رسانی پیامکی و زمان یادآوری.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sms = context.watch<SmsProvider>();
    final settings = sms.dbSettingsNotifications;
    final pal = context.pal;

    return PageScaffold(
      title: 'تنظیمات اطلاع‌رسانی',
      subtitle: 'پیامک‌های خودکار و یادآوری‌ها',
      icon: Icons.notifications_active_rounded,
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'پیامک‌های خودکار'),
                AppSwitchRow(
                  title: 'تأیید رزرو',
                  description: 'بلافاصله پس از ثبت نوبت ارسال می‌شود.',
                  value: settings.confirmationEnabled,
                  onChanged: (v) => sms.saveNotifications(settings.copyWith(confirmationEnabled: v)),
                  icon: Icons.mark_email_read_outlined,
                ),
                AppSwitchRow(
                  title: 'یادآوری نوبت',
                  description: 'پیش از زمان نوبت ارسال می‌شود.',
                  value: settings.reminderEnabled,
                  onChanged: (v) => sms.saveNotifications(settings.copyWith(reminderEnabled: v)),
                  icon: Icons.alarm_outlined,
                ),
                AppSwitchRow(
                  title: 'لغو نوبت',
                  value: settings.cancellationEnabled,
                  onChanged: (v) => sms.saveNotifications(settings.copyWith(cancellationEnabled: v)),
                  icon: Icons.event_busy_outlined,
                ),
                AppSwitchRow(
                  title: 'جابه‌جایی نوبت',
                  value: settings.rescheduleEnabled,
                  onChanged: (v) => sms.saveNotifications(settings.copyWith(rescheduleEnabled: v)),
                  icon: Icons.swap_horiz_rounded,
                ),
                AppSwitchRow(
                  title: 'ارسال نسخه به پرسنل',
                  description: 'یک نسخه از پیام تأیید برای متخصص نیز ارسال شود.',
                  value: settings.sendToStaff,
                  onChanged: (v) => sms.saveNotifications(settings.copyWith(sendToStaff: v)),
                  icon: Icons.groups_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'زمان یادآوری', subtitle: 'می‌توانید چند بازه را فعال کنید'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final hours in const [72, 24, 12, 2, 1])
                      GestureDetector(
                        onTap: () {
                          final current = [...settings.reminderHours];
                          final updated = current.contains(hours)
                              ? current.where((h) => h != hours).toList()
                              : ([...current, hours]..sort((a, b) => b.compareTo(a)));
                          sms.saveNotifications(settings.copyWith(reminderHours: updated));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: settings.reminderHours.contains(hours)
                                ? pal.primary.withValues(alpha: 0.18)
                                : pal.surfaceAlt,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: settings.reminderHours.contains(hours) ? pal.primary : pal.border,
                            ),
                          ),
                          child: Text(
                            '${FaNum.ofInt(hours)} ساعت قبل',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: pal.textPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'یادآوری‌ها در بخش «پیامک» به‌صورت نمونه ثبت می‌شوند و در این فاز ارسال واقعی انجام نمی‌شود.',
                  style: TextStyle(fontSize: 10, color: pal.textMuted, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'وضعیت پنل پیامک'),
                const SizedBox(height: 10),
                InfoRow(
                  label: 'ارائه‌دهنده',
                  value: sms.provider.providerName,
                  icon: Icons.dns_outlined,
                ),
                InfoRow(
                  label: 'وضعیت',
                  value: sms.provider.status.label,
                  icon: Icons.wifi_tethering_rounded,
                  valueColor: sms.provider.status.name == 'connected' ? pal.success : pal.warning,
                ),
                InfoRow(
                  label: 'اعتبار',
                  value: '${FaNum.ofInt(sms.stats?.credit ?? 0)} پیامک',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
