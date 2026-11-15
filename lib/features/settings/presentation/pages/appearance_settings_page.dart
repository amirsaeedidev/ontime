import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../providers/settings_provider.dart';

/// تنظیمات ظاهری و انتخاب پالت رنگ.
class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final pal = context.pal;

    return PageScaffold(
      title: 'ظاهر برنامه',
      subtitle: 'پالت رنگ و حالت نمایش',
      icon: Icons.palette_rounded,
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'پالت رنگی'),
                const SizedBox(height: 6),
                Text(
                  'دو پالت تیره (هم‌راستا با تصاویر مرجع) و یک پالت روشن در دسترس است.',
                  style: TextStyle(fontSize: 11, color: pal.textMuted, height: 1.7),
                ),
                const SizedBox(height: 14),
                for (final palette in AppPalette.all) ...[
                  GestureDetector(
                    onTap: () {
                      settings.setPalette(palette.id);
                      AppToast.show(context, 'پالت «${palette.label}» فعال شد');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: settings.paletteId == palette.id ? palette.primary : palette.border,
                          width: settings.paletteId == palette.id ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [palette.primary, palette.primaryBright]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              settings.paletteId == palette.id ? Icons.check_rounded : Icons.color_lens_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  palette.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: palette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    for (final color in [palette.primary, palette.primaryBright, palette.success, palette.purple, palette.warning])
                                      Container(
                                        width: 18,
                                        height: 18,
                                        margin: const EdgeInsets.only(left: 4),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(color: palette.borderStrong),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (settings.paletteId == palette.id)
                            StatusBadge(label: 'فعال', color: palette.success, dense: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'پیش‌نمایش'),
                const SizedBox(height: 12),
                AppCard(
                  color: pal.surfaceAlt,
                  child: Row(
                    children: [
                      IconTile(icon: Icons.content_cut_rounded, color: pal.primaryBright),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('نمونه کارت خدمت',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.textPrimary)),
                            Text('۵۵۰٬۰۰۰ تومان • ۴۰ دقیقه',
                                style: TextStyle(fontSize: 10.5, color: pal.textMuted)),
                          ],
                        ),
                      ),
                      StatusBadge(label: 'فعال', color: pal.success, dense: true),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    StatusBadge(label: 'تأیید شده', color: pal.success),
                    StatusBadge(label: 'در انتظار', color: pal.info),
                    StatusBadge(label: 'لغو شده', color: pal.danger),
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
                const SectionHeader(title: 'تنظیمات نمایش'),
                const SizedBox(height: 6),
                InfoRow(label: 'جهت متن', value: 'راست به چپ (RTL)', icon: Icons.format_textdirection_r_to_l_rounded),
                InfoRow(label: 'قلم', value: 'لاله‌زار (Lalezar)', icon: Icons.text_fields_rounded),
                InfoRow(label: 'ارقام', value: 'فارسی', icon: Icons.pin_rounded),
                InfoRow(label: 'تقویم', value: 'شمسی (جلالی)', icon: Icons.calendar_month_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
