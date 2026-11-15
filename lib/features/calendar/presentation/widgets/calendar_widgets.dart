import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/enums.dart';
import '../providers/calendar_provider.dart';

/// جدول ماه شمسی با تعداد نوبت هر روز.
class JalaliMonthGrid extends StatelessWidget {
  const JalaliMonthGrid({
    super.key,
    required this.provider,
    required this.onSelect,
    this.compact = false,
  });

  final CalendarProvider provider;
  final ValueChanged<JalaliDate> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final cells = provider.monthGrid(provider.anchor);
    final today = JalaliDate.today();

    return Column(
      children: [
        Row(
          children: [
            for (final name in JalaliDate.weekdayShortNames)
              Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(fontSize: compact ? 10 : 11, color: pal.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: compact ? 5 : 7,
            crossAxisSpacing: compact ? 5 : 7,
            childAspectRatio: compact ? 1.05 : 0.92,
          ),
          itemBuilder: (context, index) {
            final cell = cells[index];
            final appointments = provider.appointmentsOn(cell.date)
                .where((a) => a.status != AppointmentStatus.cancelled)
                .toList();
            final isSelected = cell.date.sameDay(provider.selected);
            final isToday = cell.date.sameDay(today);
            final isHoliday = provider.isHoliday(cell.date);
            return GestureDetector(
              onTap: () => onSelect(cell.date),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? pal.primary : (cell.isCurrentMonth ? pal.surfaceAlt : Colors.transparent),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isSelected
                        ? pal.primary
                        : (isToday ? pal.primary.withValues(alpha: 0.6) : pal.border.withValues(alpha: 0.6)),
                    width: isToday && !isSelected ? 1.4 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      FaNum.ofInt(cell.date.day),
                      style: TextStyle(
                        fontSize: compact ? 11 : 12.5,
                        fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isHoliday
                                ? pal.danger.withValues(alpha: 0.9)
                                : (cell.isCurrentMonth ? pal.textPrimary : pal.textMuted.withValues(alpha: 0.5))),
                      ),
                    ),
                    if (appointments.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (final a in appointments.take(3))
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : a.status.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _LegendDot(color: pal.success, label: 'تأیید شده'),
            const SizedBox(width: 10),
            _LegendDot(color: pal.info, label: 'در انتظار'),
            const SizedBox(width: 10),
            _LegendDot(color: pal.accentGlow, label: 'تکمیل شده'),
            _LegendDot(color: pal.danger, label: 'تعطیل'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 9, color: context.pal.textMuted)),
      ],
    );
  }
}

/// کارت روز با نشان تاریخ و نوبت‌ها (بازسازی تصویر مرجع تقویم).
class CalendarDayCard extends StatelessWidget {
  const CalendarDayCard({
    super.key,
    required this.date,
    required this.appointments,
    this.onAdd,
    this.onBroadcast,
    this.onTapAppointment,
  });

  final JalaliDate date;
  final List<Appointment> appointments;
  final VoidCallback? onAdd;
  final VoidCallback? onBroadcast;
  final ValueChanged<Appointment>? onTapAppointment;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final active = appointments.where((a) => a.status.isActive).length;
    final isToday = date.sameDay(JalaliDate.today());

    return AppCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(12),
      borderColor: isToday ? pal.primary.withValues(alpha: 0.5) : pal.border,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateBadge(date: date, highlighted: isToday),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date.weekdayName,
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: pal.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${FaNum.ofInt(active)} نوبت فعال',
                      style: TextStyle(fontSize: 11, color: pal.textMuted),
                    ),
                    if (isToday)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: StatusBadge(label: 'امروز', color: pal.primaryBright, dense: true),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // عرض محدود لازم است؛ در Row عرض نامحدود است و Column با
              // crossAxisAlignment.stretch نمی‌تواند روی عرض بی‌نهایت بچیند.
              SizedBox(
                width: 104,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MiniActionButton(
                      label: 'نوبت جدید',
                      icon: Icons.add_rounded,
                      color: pal.primary,
                      onTap: onAdd,
                    ),
                    const SizedBox(height: 6),
                    _MiniActionButton(
                      label: 'پیام همگانی',
                      icon: Icons.sms_rounded,
                      color: pal.purple,
                      onTap: onBroadcast,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (appointments.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final appointment in appointments) ...[
              _AppointmentRow(
                appointment: appointment,
                onTap: () => onTapAppointment?.call(appointment),
              ),
              if (appointment != appointments.last) const SizedBox(height: 7),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'نوبتی برای این روز ثبت نشده است',
                style: TextStyle(fontSize: 11, color: pal.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date, required this.highlighted});

  final JalaliDate date;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: highlighted
              ? [pal.primary, pal.primaryBright]
              : [pal.info.withValues(alpha: 0.9), pal.primary.withValues(alpha: 0.7)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: AppShadows.glow(pal.primary, opacity: 0.22, blur: 16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            FaNum.ofInt(date.day),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
          ),
          Text(
            date.monthName,
            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.9), height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({required this.label, required this.icon, required this.color, this.onTap});

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.appointment, this.onTap});

  final Appointment appointment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: pal.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: pal.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.customerName,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatusBadge(
                        label: appointment.status.label,
                        color: appointment.status.color,
                        dense: true,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          appointment.serviceName,
                          style: TextStyle(fontSize: 10, color: pal.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Fmt.time(appointment.startAt.hour, appointment.startAt.minute),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: pal.textPrimary),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: pal.success.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: pal.success.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.access_time_rounded, size: 15, color: pal.success),
            ),
          ],
        ),
      ),
    );
  }
}

/// نوار انتخاب ماه با دکمه‌های ناوبری.
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    super.key,
    required this.title,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    this.trailing,
  });

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Row(
      children: [
        CircleIconButton(icon: Icons.chevron_right_rounded, size: 34, onTap: onPrevious),
        const SizedBox(width: 6),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: pal.textPrimary),
            ),
          ),
        ),
        const SizedBox(width: 6),
        CircleIconButton(icon: Icons.chevron_left_rounded, size: 34, onTap: onNext),
        const SizedBox(width: 8),
        SoftButton(label: 'امروز', icon: Icons.today_rounded, dense: true, onTap: onToday),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

/// ستون زمانی نمای روزانه.
class DayTimeline extends StatelessWidget {
  const DayTimeline({
    super.key,
    required this.slots,
    required this.onSlotTap,
    this.hourHeight = 62,
  });

  final List<TimeSlot> slots;
  final void Function(TimeSlot slot) onSlotTap;
  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final visible = slots.where((s) => s.minute == 0 || s.isBooked).toList();
    return Column(
      children: [
        for (final slot in visible)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 46,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      FaNum.convert(slot.label),
                      style: TextStyle(fontSize: 10.5, color: pal.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSlotTap(slot),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      constraints: BoxConstraints(minHeight: hourHeight * 0.78),
                      decoration: BoxDecoration(
                        color: slot.isBooked ? pal.surfaceAlt : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: slot.isBooked
                              ? slot.appointment!.status.color.withValues(alpha: 0.45)
                              : pal.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: slot.isBooked
                          ? Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: slot.appointment!.status.color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        slot.appointment!.customerName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: pal.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${slot.appointment!.serviceName} • ${slot.appointment!.employeeName}',
                                        style: TextStyle(fontSize: 10, color: pal.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(
                                  label: slot.appointment!.status.label,
                                  color: slot.appointment!.status.color,
                                  dense: true,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(Icons.add_circle_outline_rounded, size: 14, color: pal.textMuted),
                                const SizedBox(width: 6),
                                Text(
                                  slot.isPast ? 'زمان گذشته' : 'آزاد — ثبت نوبت',
                                  style: TextStyle(fontSize: 10.5, color: pal.textMuted),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// دکمه‌های ناوبری سریع به صفحه رزرو.
class PublicBookingHint extends StatelessWidget {
  const PublicBookingHint({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      color: pal.primary.withValues(alpha: 0.08),
      borderColor: pal.primary.withValues(alpha: 0.3),
      child: Row(
        children: [
          IconTile(icon: Icons.public_rounded, color: pal.primaryBright, size: 36, radius: 11),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('لینک رزرو اختصاصی شما',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: pal.textPrimary)),
                Text('ontime.app/book/ontime-salon',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 10, color: pal.textMuted)),
              ],
            ),
          ),
          SoftButton(label: 'مشاهده', dense: true, onTap: () => context.push('/book')),
        ],
      ),
    );
  }
}
