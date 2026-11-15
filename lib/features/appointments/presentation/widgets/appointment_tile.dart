import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../data/models/appointment.dart';

/// کارت نوبت مطابق تصویر مرجع پیشخوان:
/// [چیپ ساعت] در راست، نام و خدمت در میانه، برچسب وضعیت و تاریخ در چپ.
class AppointmentTile extends StatelessWidget {
  const AppointmentTile({
    super.key,
    required this.appointment,
    this.onTap,
    this.onMore,
    this.dense = false,
    this.showReference = false,
    this.trailingAction,
  });

  final Appointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onMore;
  final bool dense;
  final bool showReference;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final accents = [pal.primaryBright, pal.success, pal.purple];
    final accent = accents[appointment.employeeId.hashCode.abs() % accents.length];
    final dateLabel = appointment.jalali.relativeLabel();

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(dense ? 10 : 12, dense ? 10 : 13, dense ? 10 : 14, dense ? 10 : 13),
      accentColor: accent,
      accentWidth: 4,
      radius: AppRadius.lg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _TimeChip(time: Fmt.time(appointment.startAt.hour, appointment.startAt.minute), accent: accent, dense: dense),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appointment.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: dense ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: pal.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      _serviceIcon(appointment.serviceName),
                      size: 12,
                      color: pal.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        appointment.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: dense ? 10.5 : 11.5,
                          color: pal.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                if (showReference) ...[
                  const SizedBox(height: 2),
                  Text(
                    'کد پیگیری: ${FaNum.convert(appointment.reference)}',
                    style: TextStyle(fontSize: 10, color: pal.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (trailingAction != null)
            trailingAction!
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusBadge.appointment(appointment.status, dense: true),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(fontSize: 10, color: pal.textMuted, fontWeight: FontWeight.w500),
                    ),
                    if (onMore != null) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onMore,
                        child: Icon(Icons.more_vert_rounded, size: 15, color: pal.textMuted),
                      ),
                    ],
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _serviceIcon(String service) {
    if (service.contains('ناخن') || service.contains('ژلیش') || service.contains('ترمیم')) return Icons.back_hand_rounded;
    if (service.contains('پوست') || service.contains('ماساژ')) return Icons.water_drop_rounded;
    if (service.contains('مو') || service.contains('کراتین') || service.contains('رنگ')) return Icons.content_cut_rounded;
    return Icons.spa_rounded;
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time, required this.accent, this.dense = false});

  final String time;
  final Color accent;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dense ? 50 : 58,
      height: dense ? 40 : 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.55), accent.withValues(alpha: 0.22)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(dense ? 11 : 14),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: dense ? 11.5 : 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// ردیف فشرده نوبت برای استفاده در تقویم و پروفایل مشتری.
class CompactAppointmentRow extends StatelessWidget {
  const CompactAppointmentRow({
    super.key,
    required this.appointment,
    this.onTap,
    this.showDate = false,
    this.trailing,
  });

  final Appointment appointment;
  final VoidCallback? onTap;
  final bool showDate;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: pal.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: pal.border),
        ),
        child: Row(
          children: [
            Icon(appointment.status.icon, size: 16, color: appointment.status.color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.customerName,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                  ),
                  Text(
                    '${appointment.serviceName} • ${appointment.employeeName}',
                    style: TextStyle(fontSize: 10.5, color: pal.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Fmt.time(appointment.startAt.hour, appointment.startAt.minute),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: pal.textPrimary),
                ),
                if (showDate)
                  Text(
                    JalaliDate.fromDateTime(appointment.startAt).short,
                    style: TextStyle(fontSize: 9.5, color: pal.textMuted),
                  ),
              ],
            ),
            if (trailing != null) ...[const SizedBox(width: 6), trailing!],
          ],
        ),
      ),
    );
  }
}
