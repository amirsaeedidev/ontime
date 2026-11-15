import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../providers/settings_provider.dart';

/// صفحه لینک عمومی رزرو و اشتراک‌گذاری آن.
class PublicLinkPage extends StatefulWidget {
  const PublicLinkPage({super.key});

  @override
  State<PublicLinkPage> createState() => _PublicLinkPageState();
}

class _PublicLinkPageState extends State<PublicLinkPage> {
  final _slug = TextEditingController();
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    _slug.text = context.read<SettingsProvider>().settings?.publicSlug ?? '';
  }

  @override
  void dispose() {
    _slug.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final business = settings.settings;
    final pal = context.pal;

    return PageScaffold(
      title: 'لینک رزرو عمومی',
      subtitle: 'مشتریان بدون نصب اپلیکیشن رزرو می‌کنند',
      icon: Icons.public_rounded,
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            gradient: LinearGradient(
              colors: [pal.primary.withValues(alpha: 0.24), pal.surface],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconTile(icon: Icons.link_rounded, color: pal.primaryBright, size: 40, radius: 12),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business?.publicUrl ?? '',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                          ),
                          Text(
                            'صفحه رزرو اختصاصی ${business?.name ?? ''}',
                            style: TextStyle(fontSize: 10.5, color: pal.textMuted),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(label: 'فعال', color: pal.success, dense: true),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _slug,
                  label: 'شناسه لینک (slug)',
                  icon: Icons.tag_rounded,
                  helper: 'فقط حروف لاتین، عدد و خط تیره',
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SolidButton(
                        label: 'ذخیره لینک',
                        icon: Icons.save_rounded,
                        height: 46,
                        onPressed: () async {
                          if (business == null) return;
                          await settings.saveBusiness(
                            business.copyWith(publicSlug: _slug.text.trim()),
                            logTitle: 'تغییر لینک رزرو',
                            logDescription: 'شناسه صفحه رزرو عمومی به‌روزرسانی شد.',
                          );
                          if (context.mounted) AppToast.show(context, 'لینک رزرو ذخیره شد');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SolidButton(
                        label: 'مشاهده صفحه',
                        icon: Icons.open_in_new_rounded,
                        height: 46,
                        outlined: true,
                        onPressed: () => context.push('/book'),
                      ),
                    ),
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
                const SectionHeader(title: 'اشتراک‌گذاری'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in const [
                      ('کپی لینک', Icons.copy_rounded),
                      ('واتس‌اپ', Icons.chat_rounded),
                      ('تلگرام', Icons.send_rounded),
                      ('اینستاگرام', Icons.camera_alt_rounded),
                      ('کد QR', Icons.qr_code_rounded),
                    ])
                      SoftButton(
                        label: item.$1,
                        icon: item.$2,
                        onTap: () => AppToast.show(context, '${item.$1}: در فاز بعدی فعال می‌شود'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'نکته‌های رزرو آنلاین'),
                const SizedBox(height: 8),
                Text(
                  '• مشتری فقط خدمت، متخصص، تاریخ و ساعت را انتخاب می‌کند.\n'
                  '• قواعد لغو و جابه‌جایی در صفحه مشتری نمایش داده می‌شود.\n'
                  '• پیامک تأیید پس از ثبت نوبت ارسال می‌شود (نمونه).',
                  style: TextStyle(fontSize: 11, color: pal.textSecondary, height: 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
