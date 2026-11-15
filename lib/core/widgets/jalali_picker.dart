import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../utils/fa_num.dart';
import '../utils/formatters.dart';
import '../utils/jalali.dart';
import 'feedback.dart';

/// انتخابگر تاریخ شمسی (بدون هیچ نمایش تاریخ میلادی).
Future<JalaliDate?> showJalaliDatePicker(
  BuildContext context, {
  JalaliDate? initial,
  JalaliDate? minDate,
  JalaliDate? maxDate,
  String title = 'انتخاب تاریخ',
}) {
  return showAppSheet<JalaliDate>(
    context,
    title: title,
    child: _JalaliPickerBody(initial: initial, minDate: minDate, maxDate: maxDate),
  );
}

class _JalaliPickerBody extends StatefulWidget {
  const _JalaliPickerBody({this.initial, this.minDate, this.maxDate});

  final JalaliDate? initial;
  final JalaliDate? minDate;
  final JalaliDate? maxDate;

  @override
  State<_JalaliPickerBody> createState() => _JalaliPickerBodyState();
}

class _JalaliPickerBodyState extends State<_JalaliPickerBody> {
  late JalaliDate _visible;
  late JalaliDate _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial ?? JalaliDate.today();
    _visible = _selected;
  }

  bool _enabled(JalaliDate date) {
    if (widget.minDate != null && date.isBefore(widget.minDate!)) return false;
    if (widget.maxDate != null && date.isAfter(widget.maxDate!)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final first = JalaliDate(_visible.year, _visible.month, 1);
    final leading = first.weekday;
    final days = first.monthLength;
    final cells = <JalaliDate?>[
      for (var i = 0; i < leading; i++) null,
      for (var d = 1; d <= days; d++) JalaliDate(first.year, first.month, d),
    ];
    final today = JalaliDate.today();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _visible = _visible.addMonths(-1)),
              icon: Icon(Icons.chevron_right_rounded, color: pal.textSecondary),
            ),
            Expanded(
              child: Text(
                '${_visible.monthName} ${FaNum.ofInt(_visible.year)}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: pal.textPrimary),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _visible = _visible.addMonths(1)),
              icon: Icon(Icons.chevron_left_rounded, color: pal.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final name in JalaliDate.weekdayShortNames)
              Expanded(
                child: Center(
                  child: Text(name, style: TextStyle(fontSize: 11, color: pal.textMuted)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ((cells.length / 7).ceil()) * 7,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            if (index >= cells.length) return const SizedBox.shrink();
            final date = cells[index];
            if (date == null) return const SizedBox.shrink();
            final isSelected = date.sameDay(_selected);
            final isToday = date.sameDay(today);
            final enabled = _enabled(date);
            return GestureDetector(
              onTap: enabled ? () => setState(() => _selected = date) : null,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? pal.primary : (isToday ? pal.surfaceAlt : Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? pal.primary : (isToday ? pal.primary.withValues(alpha: 0.5) : pal.border),
                  ),
                ),
                child: Text(
                  FaNum.ofInt(date.day),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: !enabled
                        ? pal.textMuted.withValues(alpha: 0.4)
                        : (isSelected ? Colors.white : pal.textPrimary),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: Text('تأیید ${_selected.long}'),
          ),
        ),
      ],
    );
  }
}

/// انتخاب ساعت از خانه‌های زمانی موجود.
Future<TimeOfDayLite?> showTimePickerSheet(
  BuildContext context, {
  TimeOfDayLite? initial,
  List<TimeOfDayLite>? slots,
  String title = 'انتخاب ساعت',
}) {
  final options = slots ??
      [
        for (var hour = 8; hour < 21; hour++)
          for (var minute in const [0, 15, 30, 45]) TimeOfDayLite(hour, minute),
      ];
  return showAppSheet<TimeOfDayLite>(
    context,
    title: title,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final slot in options)
          GestureDetector(
            onTap: () => Navigator.of(context).pop(slot),
            child: Container(
              width: 78,
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: initial != null && initial.hour == slot.hour && initial.minute == slot.minute
                    ? context.pal.primary
                    : context.pal.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: context.pal.border),
              ),
              child: Text(
                Fmt.time(slot.hour, slot.minute),
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: context.pal.textPrimary),
              ),
            ),
          ),
      ],
    ),
  );
}

/// ساختار سبک برای ساعت.
class TimeOfDayLite {
  const TimeOfDayLite(this.hour, this.minute);

  final int hour;
  final int minute;

  factory TimeOfDayLite.fromDate(DateTime date) => TimeOfDayLite(date.hour, date.minute);
}
