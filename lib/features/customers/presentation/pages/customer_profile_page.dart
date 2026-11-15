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
import '../../../../data/models/customer.dart';
import '../../../../data/models/enums.dart';
import '../../../appointments/presentation/providers/appointments_provider.dart';
import '../../../appointments/presentation/widgets/appointment_tile.dart';
import '../providers/customers_provider.dart';

/// پروفایل حرفه‌ای مشتری با تاریخچه، آمار و شاخص پایبندی.
class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomersProvider>();
    final appointmentsProvider = context.watch<AppointmentsProvider>();
    final pal = context.pal;
    final customer = provider.findById(customerId);

    if (customer == null) {
      return PageScaffold(
        title: 'پروفایل مشتری',
        showBackButton: true,
        child: const EmptyState(title: 'مشتری یافت نشد', description: 'این مشتری حذف شده یا وجود ندارد.'),
      );
    }

    final appointments = appointmentsProvider.allAppointments
        .where((a) => a.customerId == customer.id)
        .toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    final completed = appointments.where((a) => a.status == AppointmentStatus.completed).toList();
    final services = completed.map((a) => a.serviceName).toSet().toList();
    final upcoming = appointments.where((a) => a.status.isActive && a.startAt.isAfter(DateTime.now())).toList();

    return PageScaffold(
      title: 'پروفایل مشتری',
      subtitle: Fmt.phone(customer.phone),
      icon: Icons.person_rounded,
      showBackButton: true,
      actions: [
        SoftButton(label: 'ویرایش', icon: Icons.edit_rounded, onTap: () => context.push('/customers/${customer.id}/edit')),
        SolidButton(
          label: 'نوبت جدید',
          icon: Icons.add_rounded,
          height: 42,
          onPressed: () => context.push('/appointments/new'),
        ),
      ],
      mobileActions: [
        CircleIconButton(icon: Icons.edit_rounded, size: 38, onTap: () => context.push('/customers/${customer.id}/edit')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            gradient: LinearGradient(
              colors: [pal.primary.withValues(alpha: 0.24), pal.surface],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderColor: pal.primary.withValues(alpha: 0.35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: pal.primaryGradient,
                        boxShadow: AppShadows.glow(pal.primary, opacity: 0.3, blur: 18),
                      ),
                      child: Text(
                        customer.initials,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.fullName,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: pal.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(Fmt.phone(customer.phone), style: TextStyle(fontSize: 12, color: pal.textSecondary)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              for (final tag in customer.tags)
                                StatusBadge(label: tag, color: pal.primaryBright, dense: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ReliabilityBar(customer: customer),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _Stat(label: 'مراجعه', value: FaNum.ofInt(customer.visitCount), color: pal.primaryBright)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Stat(
                        label: 'خرید کل',
                        value: Fmt.compactMoney(customer.totalSpent).replaceAll(' تومان', ''),
                        color: pal.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _Stat(label: 'لغو', value: FaNum.ofInt(customer.cancelCount), color: pal.danger)),
                    const SizedBox(width: 8),
                    Expanded(child: _Stat(label: 'عدم حضور', value: FaNum.ofInt(customer.noShowCount), color: pal.warning)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final history = AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'تاریخچه نوبت‌ها',
                      subtitle: '${FaNum.ofInt(appointments.length)} نوبت ثبت‌شده',
                    ),
                    const SizedBox(height: 10),
                    if (appointments.isEmpty)
                      const EmptyState(compact: true, title: 'نوبتی ثبت نشده', description: '')
                    else
                      for (final appointment in appointments)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CompactAppointmentRow(
                            appointment: appointment,
                            showDate: true,
                            onTap: () => context.push('/appointments/${appointment.id}'),
                          ),
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
                        const SectionHeader(title: 'اطلاعات مشتری'),
                        const SizedBox(height: 8),
                        InfoRow(
                          label: 'تاریخ ثبت',
                          value: customer.createdAt == null ? '—' : JalaliDate.fromDateTime(customer.createdAt!).long,
                          icon: Icons.calendar_today_rounded,
                        ),
                        InfoRow(
                          label: 'آخرین مراجعه',
                          value: customer.lastVisitAt == null ? 'ندارد' : JalaliDate.fromDateTime(customer.lastVisitAt!).long,
                          icon: Icons.history_rounded,
                        ),
                        InfoRow(
                          label: 'نوبت آینده',
                          value: upcoming.isEmpty ? 'ندارد' : upcoming.first.jalali.long,
                          icon: Icons.event_available_rounded,
                          valueColor: upcoming.isEmpty ? null : pal.success,
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Text('یادداشت داخلی', style: TextStyle(fontSize: 11.5, color: pal.textMuted)),
                            const Spacer(),
                            SoftButton(
                              label: 'ویرایش',
                              icon: Icons.edit_rounded,
                              dense: true,
                              onTap: () => context.push('/customers/${customer.id}/edit'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          customer.notes.isEmpty ? 'یادداشتی ثبت نشده است.' : customer.notes,
                          style: TextStyle(fontSize: 11.5, color: pal.textSecondary, height: 1.9),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'خدمات دریافت‌شده'),
                        const SizedBox(height: 10),
                        if (services.isEmpty)
                          Text('خدمتی ثبت نشده است.', style: TextStyle(fontSize: 11, color: pal.textMuted))
                        else
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final service in services)
                                StatusBadge(label: service, color: pal.success, dense: true),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              );

              if (!wide) {
                return Column(children: [side, const SizedBox(height: 12), history]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: history),
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

class _ReliabilityBar extends StatelessWidget {
  const _ReliabilityBar({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final value = customer.reliability / 100;
    final color = customer.reliability >= 70 ? pal.success : (customer.reliability >= 50 ? pal.warning : pal.danger);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.workspace_premium_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              customer.reliabilityLabel,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
            ),
            const Spacer(),
            Text(
              '${FaNum.ofInt(customer.reliability)}٪',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: pal.surfaceAlt,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9, color: pal.textMuted)),
        ],
      ),
    );
  }
}
