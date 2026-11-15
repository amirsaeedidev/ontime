import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/sms_message.dart';
import '../providers/sms_provider.dart';

/// مدیریت قالب‌های پیامک و زمان‌بندی یادآوری‌ها.
class SmsTemplatesPage extends StatelessWidget {
  const SmsTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmsProvider>();
    final pal = context.pal;

    return PageScaffold(
      title: 'قالب‌های پیامک',
      subtitle: 'ویرایش متن‌ها و افزودن متغیرهای پویا',
      icon: Icons.article_rounded,
      showBackButton: true,
      actions: [
        SoftButton(label: 'تنظیمات پنل', icon: Icons.settings_rounded, onTap: () => context.push('/sms/settings')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'یادآوری خودکار', subtitle: 'زمان ارسال یادآوری پیش از نوبت'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final hours in const [24, 12, 2])
                      GestureDetector(
                        onTap: () {
                          final current = [...provider.dbSettingsNotifications.reminderHours];
                          final updated = current.contains(hours)
                              ? current.where((h) => h != hours).toList()
                              : ([...current, hours]..sort((a, b) => b.compareTo(a)));
                          provider.saveNotifications(
                            provider.dbSettingsNotifications.copyWith(reminderHours: updated),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: provider.dbSettingsNotifications.reminderHours.contains(hours)
                                ? pal.primary.withValues(alpha: 0.18)
                                : pal.surfaceAlt,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: provider.dbSettingsNotifications.reminderHours.contains(hours)
                                  ? pal.primary
                                  : pal.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.alarm_rounded, size: 13, color: pal.primaryBright),
                              const SizedBox(width: 5),
                              Text(
                                '${FaNum.ofInt(hours)} ساعت قبل',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: pal.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'با کلیک روی هر بازه، زمان ارسال یادآوری فعال یا غیرفعال می‌شود.',
                  style: TextStyle(fontSize: 10.5, color: pal.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final template in provider.templates) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconTile(
                        icon: template.isEnabled ? Icons.mark_email_read_rounded : Icons.pause_circle_outline_rounded,
                        color: template.isEnabled ? pal.primary : pal.textMuted,
                        size: 34,
                        radius: 11,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template.label,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: pal.textPrimary),
                            ),
                            Text(
                              template.isEnabled ? 'فعال' : 'غیرفعال',
                              style: TextStyle(
                                fontSize: 10,
                                color: template.isEnabled ? pal.success : pal.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: template.isEnabled,
                        activeTrackColor: pal.primary,
                        activeThumbColor: Colors.white,
                        onChanged: (v) => provider.saveTemplate(template.copyWith(isEnabled: v)),
                      ),
                      SoftButton(
                        label: 'ویرایش',
                        icon: Icons.edit_rounded,
                        dense: true,
                        onTap: () => _editTemplate(context, template),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: pal.surfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: pal.border),
                    ),
                    child: Text(
                      template.body,
                      style: TextStyle(fontSize: 11, color: pal.textSecondary, height: 1.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'متغیرهای قابل استفاده'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final placeholder in SmsTemplate.placeholders)
                      StatusBadge(label: placeholder, color: pal.purple, dense: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'تنظیمات اطلاع‌رسانی'),
                const SizedBox(height: 8),
                _NotificationToggles(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editTemplate(BuildContext context, SmsTemplate template) async {
    final controller = TextEditingController(text: template.body);
    final sms = context.read<SmsProvider>();
    final result = await showAppSheet<bool>(
      context,
      title: 'ویرایش قالب «${template.label}»',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: controller,
            label: 'متن پیامک',
            maxLines: 6,
            helper: 'متغیرها را با آکولاد وارد کنید، مانند {نام مشتری}',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final placeholder in SmsTemplate.placeholders)
                ActionChip(
                  label: Text(placeholder, style: const TextStyle(fontSize: 10)),
                  onPressed: () {
                    controller.text = '${controller.text} $placeholder';
                  },
                ),
            ],
          ),
        ],
      ),
    );
    if (result == true) {
      await sms.saveTemplate(template.copyWith(body: controller.text.trim()));
      if (context.mounted) {
        AppToast.show(context, 'قالب پیامک ذخیره شد');
      }
    }
    controller.dispose();
  }
}

class _NotificationToggles extends StatelessWidget {
  const _NotificationToggles();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SmsProvider>();
    final settings = provider.dbSettingsNotifications;
    return Column(
      children: [
        AppSwitchRow(
          title: 'پیامک تأیید رزرو',
          description: 'بلافاصله پس از ثبت نوبت ارسال می‌شود.',
          value: settings.confirmationEnabled,
          onChanged: (v) => provider.saveNotifications(settings.copyWith(confirmationEnabled: v)),
          icon: Icons.mark_email_read_outlined,
        ),
        AppSwitchRow(
          title: 'پیامک یادآوری',
          description: 'طبق زمان‌بندی انتخاب‌شده پیش از نوبت ارسال می‌شود.',
          value: settings.reminderEnabled,
          onChanged: (v) => provider.saveNotifications(settings.copyWith(reminderEnabled: v)),
          icon: Icons.alarm_outlined,
        ),
        AppSwitchRow(
          title: 'پیامک لغو نوبت',
          value: settings.cancellationEnabled,
          onChanged: (v) => provider.saveNotifications(settings.copyWith(cancellationEnabled: v)),
          icon: Icons.event_busy_outlined,
        ),
        AppSwitchRow(
          title: 'پیامک جابه‌جایی',
          value: settings.rescheduleEnabled,
          onChanged: (v) => provider.saveNotifications(settings.copyWith(rescheduleEnabled: v)),
          icon: Icons.swap_horiz_rounded,
        ),
      ],
    );
  }
}
