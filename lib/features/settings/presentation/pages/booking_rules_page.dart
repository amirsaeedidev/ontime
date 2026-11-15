import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/business_settings.dart';
import '../providers/settings_provider.dart';

/// قواعد رزرو، لغو و جابه‌جایی نوبت.
class BookingRulesPage extends StatefulWidget {
  const BookingRulesPage({super.key});

  @override
  State<BookingRulesPage> createState() => _BookingRulesPageState();
}

class _BookingRulesPageState extends State<BookingRulesPage> {
  late BookingRules _rules;
  final _maxReschedules = TextEditingController();
  final _minHours = TextEditingController();
  final _advanceDays = TextEditingController();
  final _interval = TextEditingController();
  bool _prefilled = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    _rules = context.read<SettingsProvider>().rules;
    _maxReschedules.text = _rules.maxReschedules.toString();
    _minHours.text = _rules.minHoursBeforeChange.toString();
    _advanceDays.text = _rules.maxAdvanceDays.toString();
    _interval.text = _rules.slotIntervalMinutes.toString();
  }

  @override
  void dispose() {
    _maxReschedules.dispose();
    _minHours.dispose();
    _advanceDays.dispose();
    _interval.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = _rules.copyWith(
      maxReschedules: int.tryParse(FaNum.toLatin(_maxReschedules.text)) ?? 1,
      minHoursBeforeChange: int.tryParse(FaNum.toLatin(_minHours.text)) ?? 2,
      maxAdvanceDays: int.tryParse(FaNum.toLatin(_advanceDays.text)) ?? 30,
      slotIntervalMinutes: int.tryParse(FaNum.toLatin(_interval.text)) ?? 15,
    );
    await context.read<SettingsProvider>().updateRules(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    AppToast.show(context, 'قواعد رزرو ذخیره شد');
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return PageScaffold(
      title: 'قواعد رزرو و لغو',
      subtitle: 'محدودیت‌های رزرو آنلاین و تغییر نوبت',
      icon: Icons.rule_rounded,
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'رزرو آنلاین'),
                AppSwitchRow(
                  title: 'امکان رزرو آنلاین توسط مشتری',
                  description: 'اگر غیرفعال شود، صفحه رزرو عمومی فقط نمایشی خواهد بود.',
                  value: _rules.allowOnlineBooking,
                  onChanged: (v) => setState(() => _rules = _rules.copyWith(allowOnlineBooking: v)),
                  icon: Icons.public_rounded,
                ),
                AppSwitchRow(
                  title: 'نیاز به تأیید دستی نوبت‌ها',
                  description: 'نوبت‌های جدید در وضعیت «در انتظار» ثبت می‌شوند.',
                  value: _rules.requireConfirmation,
                  onChanged: (v) => setState(() => _rules = _rules.copyWith(requireConfirmation: v)),
                  icon: Icons.verified_outlined,
                ),
                AppSwitchRow(
                  title: 'جلوگیری از تداخل زمانی',
                  description: 'برای هر متخصص تنها یک نوبت در هر بازه مجاز است.',
                  value: _rules.preventOverlap,
                  onChanged: (v) => setState(() => _rules = _rules.copyWith(preventOverlap: v)),
                  icon: Icons.block_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'لغو و جابه‌جایی'),
                AppSwitchRow(
                  title: 'اجازه لغو نوبت توسط مشتری',
                  value: _rules.allowCustomerCancel,
                  onChanged: (v) => setState(() => _rules = _rules.copyWith(allowCustomerCancel: v)),
                  icon: Icons.event_busy_outlined,
                ),
                AppSwitchRow(
                  title: 'اجازه جابه‌جایی نوبت توسط مشتری',
                  value: _rules.allowReschedule,
                  onChanged: (v) => setState(() => _rules = _rules.copyWith(allowReschedule: v)),
                  icon: Icons.swap_horiz_rounded,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _maxReschedules,
                        label: 'حداکثر تعداد جابه‌جایی',
                        icon: Icons.repeat_rounded,
                        numericFa: true,
                        helper: 'پیش‌فرض: ۱ بار',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        controller: _minHours,
                        label: 'حداقل زمان قبل از تغییر (ساعت)',
                        icon: Icons.timer_outlined,
                        numericFa: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _advanceDays,
                        label: 'حداکثر روز رزرو جلوتر',
                        icon: Icons.date_range_rounded,
                        numericFa: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppTextField(
                        controller: _interval,
                        label: 'فاصله خانه‌های زمانی (دقیقه)',
                        icon: Icons.grid_view_rounded,
                        numericFa: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            color: pal.dangerSoft,
            borderColor: pal.danger.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: pal.danger),
                    const SizedBox(width: 6),
                    Text(
                      'پیامدهای لغو مکرر',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: pal.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'مشتریانی که بیش از ${FaNum.ofInt(_rules.cancelPenaltyCount)} بار نوبت خود را لغو کنند در گزارش پایبندی مشخص می‌شوند.',
                  style: TextStyle(fontSize: 11, color: pal.textSecondary, height: 1.8),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SoftButton(label: 'تاریخچه لغوها', icon: Icons.history_rounded, dense: true, onTap: () {}),
                    SoftButton(label: 'گزارش مشتریان', icon: Icons.people_rounded, dense: true, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SolidButton(label: 'ذخیره قواعد', icon: Icons.save_rounded, loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
