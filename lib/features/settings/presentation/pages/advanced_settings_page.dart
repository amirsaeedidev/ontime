import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/employee.dart';
import '../../../../data/models/enums.dart';
import '../providers/settings_provider.dart';

/// تنظیمات پیشرفته: شیفت‌های کاری و تعطیلات هفتگی — بازسازی تصویر مرجع.
class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  final Map<int, List<Shift>> _schedules = {};
  List<int> _holidays = [];
  bool _scheduleExpanded = true;
  bool _holidaysExpanded = true;
  bool _saving = false;
  bool _prefilled = false;
  int _activeDay = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final settings = context.read<SettingsProvider>();
    for (var day = 0; day < 7; day++) {
      _schedules[day] = settings.workingHours[day] ?? const [];
    }
    _holidays = [...settings.holidays];
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<SettingsProvider>().updateWorkingHours(
          Map<int, List<Shift>>.from(_schedules.map((k, v) => MapEntry(k, [...v]))),
          holidays: _holidays,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    AppToast.show(context, 'تغییرات با موفقیت ذخیره شد');
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;

    return PageScaffold(
      title: 'تنظیمات پیشرفته',
      subtitle: 'پیکربندی ۱۴۰۵',
      icon: Icons.tune_rounded,
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ExpandablePanel(
            title: 'زمان‌بندی فعالیت',
            subtitle: 'برای بستن کلیک کنید',
            icon: Icons.schedule_rounded,
            accent: pal.primary,
            gradient: [pal.info.withValues(alpha: 0.22), pal.backgroundAlt],
            expanded: _scheduleExpanded,
            onToggle: () => setState(() => _scheduleExpanded = !_scheduleExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => setState(() {
                        final day = 0;
                        _schedules[day] = [...(_schedules[day] ?? const []), const Shift(start: '08:30', end: '13:00')];
                      }),
                      icon: const Icon(Icons.add_rounded, size: 15),
                      label: const Text('شیفت جدید', style: TextStyle(fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: pal.primaryBright,
                        side: BorderSide(color: pal.primary.withValues(alpha: 0.6)),
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'مدیریت شیفت‌های کاری',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: pal.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var day = 0; day < 7; day++)
                      GestureDetector(
                        onTap: () => setState(() => _activeDay = day),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeDay == day
                                ? pal.primaryBright.withValues(alpha: 0.2)
                                : pal.backgroundAlt.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: _activeDay == day ? pal.primaryBright : pal.border,
                            ),
                          ),
                          child: Text(
                            WeekDay.names[day],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: _activeDay == day ? FontWeight.w700 : FontWeight.w500,
                              color: _activeDay == day ? pal.textPrimary : pal.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDayShifts(context, _activeDay),
                const SizedBox(height: 4),
                Text(
                  'هر روز می‌توانید چند شیفت مستقل تعریف کنید؛ خانه‌های زمانی بر همین اساس ساخته می‌شوند.',
                  style: TextStyle(fontSize: 10, color: pal.textMuted, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ExpandablePanel(
            title: 'تعطیلات هفتگی',
            subtitle: 'برای بستن کلیک کنید',
            icon: Icons.event_busy_rounded,
            accent: pal.danger,
            gradient: [const Color(0xFF7F1D3A).withValues(alpha: 0.32), const Color(0xFF2A0F1A).withValues(alpha: 0.9)],
            expanded: _holidaysExpanded,
            onToggle: () => setState(() => _holidaysExpanded = !_holidaysExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'روزهای غیرفعال هفته را انتخاب کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: pal.textSecondary),
                ),
                const SizedBox(height: 12),
                ChipSelector(
                  options: WeekDay.names,
                  selected: _holidays,
                  dangerSelected: true,
                  onToggle: (index) => setState(() {
                    _holidays = _holidays.contains(index)
                        ? _holidays.where((d) => d != index).toList()
                        : [..._holidays, index];
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  'روزهای انتخاب شده به عنوان تعطیل نمایش داده می‌شوند و امکان رزرو در آن‌ها وجود ندارد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: pal.textMuted, height: 1.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GradientCta(
            title: 'تأیید و ثبت تغییرات',
            subtitle: '${FaNum.ofInt(_holidays.length)} روز تعطیل • ${FaNum.ofInt(_schedules.values.where((s) => s.isNotEmpty).length)} روز فعال',
            icon: Icons.save_rounded,
            height: 66,
            onPressed: _saving ? () {} : _save,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.push('/settings/rules'),
            child: Text('تنظیم قواعد رزرو و لغو', style: TextStyle(fontSize: 11.5, color: pal.primaryBright)),
          ),
        ],
      ),
    );
  }

  Widget _buildDayShifts(BuildContext context, int day) {
    final pal = context.pal;
    final shifts = _schedules[day] ?? const <Shift>[];
    final isHoliday = _holidays.contains(day);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: pal.backgroundAlt.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: pal.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    WeekDay.names[day],
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                  ),
                ),
                Expanded(
                  child: Text(
                    isHoliday ? 'تعطیل هفتگی' : (shifts.isEmpty ? 'بدون شیفت' : '${FaNum.ofInt(shifts.length)} شیفت'),
                    style: TextStyle(fontSize: 10, color: isHoliday ? pal.danger : pal.textMuted),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'افزودن شیفت',
                  onPressed: () => setState(() {
                    _schedules[day] = [...shifts, const Shift(start: '16:00', end: '21:00')];
                  }),
                  icon: Icon(Icons.add_circle_outline_rounded, size: 16, color: pal.primaryBright),
                ),
              ],
            ),
            for (var index = 0; index < shifts.length; index++)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TimeDropdown(
                        value: shifts[index].start,
                        onChanged: (v) => setState(() {
                          final list = [..._schedules[day]!];
                          list[index] = list[index].copyWith(start: v);
                          _schedules[day] = list;
                        }),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TimeDropdown(
                        value: shifts[index].end,
                        onChanged: (v) => setState(() {
                          final list = [..._schedules[day]!];
                          list[index] = list[index].copyWith(end: v);
                          _schedules[day] = list;
                        }),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() {
                        final list = [..._schedules[day]!]..removeAt(index);
                        _schedules[day] = list;
                      }),
                      icon: Icon(Icons.delete_outline_rounded, size: 17, color: pal.danger),
                    ),
                  ],
                ),
              ),
            if (shifts.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  shifts.map((s) => s.label).join(' • '),
                  style: TextStyle(fontSize: 9.5, color: pal.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpandablePanel extends StatelessWidget {
  const _ExpandablePanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.gradient,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<Color> gradient;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: accent.withValues(alpha: 0.4)),
                    ),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: pal.textPrimary),
                        ),
                        Text(subtitle, style: TextStyle(fontSize: 10, color: pal.textMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0 : 0.5,
                    duration: AppDurations.fast,
                    child: Icon(Icons.keyboard_arrow_up_rounded, color: accent, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: AppDurations.normal,
            crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  Divider(color: accent.withValues(alpha: 0.2), height: 1),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
