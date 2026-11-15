import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/jalali_picker.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/enums.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../providers/appointments_provider.dart';
import '../widgets/appointment_tile.dart';
import 'appointment_actions.dart';

/// جزئیات کامل یک نوبت با اقدامات مدیریتی.
class AppointmentDetailsPage extends StatelessWidget {
  const AppointmentDetailsPage({super.key, required this.appointmentId});

  final String appointmentId;

  Future<void> _reschedule(BuildContext context, Appointment appointment) async {
    final date = await showJalaliDatePicker(
      context,
      initial: appointment.jalali,
      minDate: JalaliDate.today(),
      maxDate: JalaliDate.today().addDays(90),
      title: 'انتخاب تاریخ جدید',
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePickerSheet(context, initial: TimeOfDayLite.fromDate(appointment.startAt));
    if (time == null || !context.mounted) return;

    final provider = context.read<AppointmentsProvider>();
    final newStart = date.toDateTime().add(Duration(hours: time.hour, minutes: time.minute));
    final conflict = await provider.checkConflict(
      employeeId: appointment.employeeId,
      startAt: newStart,
      durationMinutes: appointment.durationMinutes,
      ignoreId: appointment.id,
    );
    if (!context.mounted) return;
    if (conflict != null) {
      AppToast.show(context, 'این زمان برای ${appointment.employeeName} رزرو شده است.', success: false);
      return;
    }
    await provider.reschedule(appointment, newStart);
    if (context.mounted) AppToast.show(context, 'نوبت جابه‌جا شد');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentsProvider>();
    final appointment = provider.appointmentById(appointmentId);
    final pal = context.pal;

    if (appointment == null) {
      return PageScaffold(
        title: 'جزئیات نوبت',
        showBackButton: true,
        child: const EmptyState(title: 'نوبت یافت نشد', description: 'این نوبت حذف شده یا وجود ندارد.'),
      );
    }

    final customer = context.watch<CustomersProvider>().findById(appointment.customerId);
    final history = provider.allAppointments
        .where((a) => a.customerId == appointment.customerId && a.id != appointment.id)
        .toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));

    return PageScaffold(
      title: 'جزئیات نوبت',
      subtitle: 'کد پیگیری ${FaNum.convert(appointment.reference)}',
      icon: Icons.event_available_rounded,
      showBackButton: true,
      actions: [
        SoftButton(
          label: 'ویرایش',
          icon: Icons.edit_rounded,
          onTap: () => context.push('/appointments/${appointment.id}/edit'),
        ),
        SoftButton(
          label: 'اقدامات',
          icon: Icons.more_horiz_rounded,
          onTap: () => showAppointmentActions(context, appointment),
        ),
      ],
      mobileActions: [
        CircleIconButton(
          icon: Icons.edit_rounded,
          size: 38,
          onTap: () => context.push('/appointments/${appointment.id}/edit'),
        ),
        CircleIconButton(icon: Icons.more_horiz_rounded, size: 38, onTap: () => showAppointmentActions(context, appointment)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusHero(appointment: appointment),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final details = AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'اطلاعات نوبت'),
                    const SizedBox(height: 10),
                    InfoRow(label: 'خدمت', value: appointment.serviceName, icon: Icons.content_cut_rounded),
                    InfoRow(label: 'متخصص', value: appointment.employeeName, icon: Icons.badge_outlined),
                    InfoRow(label: 'تاریخ', value: appointment.jalali.long, icon: Icons.calendar_today_rounded),
                    InfoRow(
                      label: 'ساعت',
                      value: Fmt.range(
                        appointment.startAt.hour,
                        appointment.startAt.minute,
                        appointment.endAt.hour,
                        appointment.endAt.minute,
                      ),
                      icon: Icons.access_time_rounded,
                    ),
                    InfoRow(label: 'مدت', value: Fmt.duration(appointment.durationMinutes), icon: Icons.timelapse_rounded),
                    InfoRow(
                      label: 'مبلغ',
                      value: Fmt.money(appointment.price),
                      icon: Icons.payments_rounded,
                      valueColor: pal.success,
                    ),
                    InfoRow(label: 'ثبت توسط', value: appointment.createdBy, icon: Icons.person_outline_rounded),
                    if (appointment.note.isNotEmpty) ...[
                      const Divider(height: 20),
                      Text('یادداشت', style: TextStyle(fontSize: 11.5, color: pal.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        appointment.note,
                        style: TextStyle(fontSize: 12, color: pal.textSecondary, height: 1.8),
                      ),
                    ],
                    if (appointment.cancelReason != null) ...[
                      const Divider(height: 20),
                      Text(
                        'دلیل لغو: ${appointment.cancelReason}',
                        style: TextStyle(fontSize: 11.5, color: pal.danger),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SoftButton(
                            label: 'جابه‌جایی',
                            icon: Icons.swap_horiz_rounded,
                            onTap: () => _reschedule(context, appointment),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SoftButton(
                            label: 'مشاهده مشتری',
                            icon: Icons.person_rounded,
                            onTap: () => context.push('/customers/${appointment.customerId}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              final side = Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'مشتری'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            AvatarBadge(name: appointment.customerName, size: 46, color: pal.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.customerName,
                                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                                  ),
                                  Text(
                                    Fmt.phone(appointment.customerPhone),
                                    style: TextStyle(fontSize: 11, color: pal.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: 'مراجعه',
                                value: FaNum.ofInt(customer?.visitCount ?? 0),
                                color: pal.primaryBright,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MiniStat(
                                label: 'خرید کل',
                                value: Fmt.compactMoney(customer?.totalSpent ?? 0).replaceAll(' تومان', ''),
                                color: pal.success,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MiniStat(
                                label: 'لغو',
                                value: FaNum.ofInt(customer?.cancelCount ?? 0),
                                color: pal.danger,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: 'تاریخچه نوبت‌های مشتری', subtitle: '${FaNum.ofInt(history.length)} نوبت دیگر'),
                        const SizedBox(height: 8),
                        if (history.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text('نوبت دیگری ثبت نشده است.',
                                style: TextStyle(fontSize: 11.5, color: pal.textMuted)),
                          )
                        else
                          for (final item in history.take(5)) ...[
                            CompactAppointmentRow(
                              appointment: item,
                              showDate: true,
                              onTap: () => context.push('/appointments/${item.id}'),
                            ),
                            const SizedBox(height: 6),
                          ],
                      ],
                    ),
                  ),
                ],
              );

              if (!wide) {
                return Column(children: [details, const SizedBox(height: 12), side]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: details),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: side),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final status = appointment.status;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [status.color.withValues(alpha: 0.32), pal.surface],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: status.color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(label: status.label, color: status.color, filled: true, icon: status.icon),
              const Spacer(),
              Text(
                appointment.jalali.relativeLabel(),
                style: TextStyle(fontSize: 11.5, color: pal.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Fmt.time(appointment.startAt.hour, appointment.startAt.minute),
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: pal.textPrimary, height: 1.1),
                  ),
                  Text(
                    appointment.jalali.long,
                    style: TextStyle(fontSize: 11.5, color: pal.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    appointment.customerName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: pal.textPrimary),
                  ),
                  Text(
                    appointment.employeeName,
                    style: TextStyle(fontSize: 11, color: pal.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SoftButton(
                  label: 'تأیید',
                  icon: Icons.verified_rounded,
                  color: pal.success,
                  onTap: () => context.read<AppointmentsProvider>().changeStatus(appointment, AppointmentStatus.confirmed),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SoftButton(
                  label: 'تکمیل',
                  icon: Icons.task_alt_rounded,
                  color: pal.accentGlow,
                  onTap: () => context.read<AppointmentsProvider>().changeStatus(appointment, AppointmentStatus.completed),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SoftButton(
                  label: 'لغو',
                  icon: Icons.event_busy_rounded,
                  color: pal.danger,
                  onTap: () async {
                    final confirmed = await showConfirmDialog(
                      context,
                      title: 'لغو نوبت',
                      message: 'آیا از لغو این نوبت مطمئن هستید؟',
                      confirmLabel: 'لغو نوبت',
                      destructive: true,
                    );
                    if (confirmed && context.mounted) {
                      await context
                          .read<AppointmentsProvider>()
                          .changeStatus(appointment, AppointmentStatus.cancelled, reason: 'لغو توسط پرسنل');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9.5, color: pal.textMuted)),
        ],
      ),
    );
  }
}
