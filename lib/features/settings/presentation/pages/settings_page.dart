import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../providers/settings_provider.dart';

/// مرکز تنظیمات؛ دسترسی به همه پیکربندی‌ها و ماژول‌های مدیریتی.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final pal = context.pal;
    final business = settings.settings;

    final items = <_SettingEntry>[
      _SettingEntry('اطلاعات مجموعه', 'نام، تماس، آدرس و شبکه‌های اجتماعی', Icons.storefront_rounded, pal.primaryBright, '/settings/business'),
      _SettingEntry('ساعات کاری و تعطیلات', 'مدیریت شیفت‌ها و روزهای تعطیل', Icons.schedule_rounded, pal.accentGlow, '/settings/hours'),
      _SettingEntry('قواعد رزرو و لغو', 'محدودیت لغو، جابه‌جایی و تداخل', Icons.rule_rounded, pal.success, '/settings/rules'),
      _SettingEntry('تنظیمات پیامک', 'پنل پیامک، قالب‌ها و یادآوری', Icons.sms_rounded, pal.purple, '/sms/settings'),
      _SettingEntry('اطلاع‌رسانی', 'پیامک‌های خودکار و زمان‌بندی', Icons.notifications_active_outlined, pal.warning, '/settings/notifications'),
      _SettingEntry('موقعیت مکانی', 'نقشه، مختصات و آدرس', Icons.location_on_rounded, pal.danger, '/settings/location'),
      _SettingEntry('ظاهر برنامه', 'پالت رنگ و حالت نمایش', Icons.palette_rounded, pal.primary, '/settings/appearance'),
      _SettingEntry('دسترسی‌ها و نقش‌ها', 'مجوزهای پرسنل و نقش‌ها', Icons.security_rounded, pal.info, '/settings/permissions'),
      _SettingEntry('مدیریت خدمات', 'خدمات، قیمت و زمان‌بندی', Icons.content_cut_rounded, pal.primaryBright, '/services'),
      _SettingEntry('مدیریت پرسنل', 'پرسنل، برنامه کاری و مجوزها', Icons.badge_rounded, pal.purple, '/employees'),
      _SettingEntry('لینک رزرو عمومی', 'آدرس صفحه رزرو مشتریان', Icons.public_rounded, pal.success, '/settings/link'),
      _SettingEntry('گزارش فعالیت‌ها', 'ردگیری رویدادهای سیستم', Icons.history_rounded, pal.textSecondary, '/activity'),
    ];

    return PageScaffold(
      title: 'تنظیمات',
      subtitle: 'پیکربندی کامل مجموعه',
      icon: Icons.settings_rounded,
      actions: [
        SoftButton(label: 'صفحه رزرو', icon: Icons.public_rounded, onTap: () => context.push('/book')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            gradient: LinearGradient(
              colors: [pal.primary.withValues(alpha: 0.22), pal.surface],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            child: Row(
              children: [
                AvatarBadge(name: settings.ownerName, size: 52, color: pal.primaryBright),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business?.name ?? 'مجموعه',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: pal.textPrimary),
                      ),
                      Text(
                        '${settings.ownerName} • ${settings.ownerRole}',
                        style: TextStyle(fontSize: 11, color: pal.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 12, color: pal.success),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'پنل پیامک: ${settings.smsProvider.status.label}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 10, color: pal.success),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CountPill(value: settings.totalUnread, icon: Icons.notifications_none_rounded),
                    const SizedBox(height: 6),
                    Text('نسخه ۱٫۰٫۰', style: TextStyle(fontSize: 9, color: pal.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);
              final itemWidth = (width - 10 * (columns - 1)) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: itemWidth,
                      child: AppCard(
                        onTap: () => context.push(item.route),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            IconTile(icon: item.icon, color: item.color, size: 38, radius: 12),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: pal.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    item.subtitle,
                                    style: TextStyle(fontSize: 10, color: pal.textMuted, height: 1.6),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_left_rounded, size: 18, color: pal.textMuted),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'لینک رزرو عمومی', subtitle: business?.publicUrl ?? ''),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: pal.surfaceAlt,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: pal.border),
                        ),
                        child: Text(
                          business?.fullUrl ?? '',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(fontSize: 11, color: pal.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SoftButton(
                      label: 'کپی',
                      icon: Icons.copy_rounded,
                      onTap: () => AppToast.show(context, 'لینک کپی شد (${FaNum.ofInt(1)} مورد)'),
                    ),
                    const SizedBox(width: 8),
                    SolidButton(
                      label: 'مشاهده',
                      height: 44,
                      onPressed: () => context.push('/book'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingEntry {
  const _SettingEntry(this.title, this.subtitle, this.icon, this.color, this.route);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
}
