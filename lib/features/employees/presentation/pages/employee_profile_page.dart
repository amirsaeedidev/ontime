import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/enums.dart';
import '../../../appointments/presentation/providers/appointments_provider.dart';
import '../../../appointments/presentation/widgets/appointment_tile.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../providers/employees_provider.dart';

/// پروفایل پرسنل با برنامه کاری و نوبت‌های آینده.
class EmployeeProfilePage extends StatelessWidget {
  const EmployeeProfilePage({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();
    final services = context.watch<ServicesProvider>();
    final appointments = context.watch<AppointmentsProvider>();
    final pal = context.pal;
    final employee = provider.byIdSync(employeeId);

    if (employee == null) {
      return PageScaffold(
        title: 'پروفایل پرسنل',
        showBackButton: true,
        child: const EmptyState(title: 'پرسنل یافت نشد'),
      );
    }

    final today = DateTime.now();
    final upcoming = appointments.allAppointments
        .where((a) => a.employeeId == employee.id && a.startAt.isAfter(today) && a.status.isActive)
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final color = Color(employee.colorValue);

    return PageScaffold(
      title: 'پروفایل پرسنل',
      subtitle: employee.title,
      icon: Icons.badge_rounded,
      showBackButton: true,
      actions: [
        SoftButton(label: 'ویرایش', icon: Icons.edit_rounded, onTap: () => context.push('/employees/${employee.id}/edit')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.28), pal.surface],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  child: Text(
                    employee.initials,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: pal.textPrimary),
                      ),
                      Text(
                        '${employee.title} • ${employee.role.label}',
                        style: TextStyle(fontSize: 11, color: pal.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 13, color: pal.warning),
                          Text(FaNum.convert(employee.rating.toStringAsFixed(1)),
                              style: TextStyle(fontSize: 10.5, color: pal.textSecondary)),
                          const SizedBox(width: 10),
                          Text(Fmt.phone(employee.phone), style: TextStyle(fontSize: 10.5, color: pal.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: employee.isActive ? 'فعال' : 'غیرفعال',
                  color: employee.isActive ? pal.success : pal.textMuted,
                  dense: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'برنامه هفتگی'),
                const SizedBox(height: 12),
                for (var day = 0; day < 7; day++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 66,
                          child: Text(
                            WeekDay.names[day],
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: pal.textSecondary),
                          ),
                        ),
                        Expanded(
                          child: employee.worksOn(day)
                              ? Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    for (final shift in employee.shiftsFor(day))
                                      StatusBadge(label: shift.label, color: pal.primaryBright, dense: true),
                                  ],
                                )
                              : Text('تعطیل', style: TextStyle(fontSize: 10.5, color: pal.danger)),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 20),
                const SectionHeader(title: 'خدمات'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final service in services.items.where((s) => employee.serviceIds.contains(s.id)))
                      StatusBadge(label: service.title, color: pal.success, dense: true),
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
                SectionHeader(title: 'نوبت‌های آینده', subtitle: '${FaNum.ofInt(upcoming.length)} نوبت'),
                const SizedBox(height: 10),
                if (upcoming.isEmpty)
                  const EmptyState(compact: true, title: 'نوبتی ثبت نشده', description: '')
                else
                  for (final appointment in upcoming.take(6))
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
          ),
        ],
      ),
    );
  }
}
