import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/employee.dart';
import '../../../../data/models/enums.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../providers/employees_provider.dart';

/// مدیریت پرسنل و مسیرهای خدمت.
class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();
    final services = context.watch<ServicesProvider>();
    final pal = context.pal;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return PageScaffold(
      title: 'مدیریت پرسنل',
      subtitle: '${FaNum.ofInt(provider.activeCount)} متخصص فعال',
      icon: Icons.badge_rounded,
      actions: [
        SoftButton(label: 'ساعات کاری', icon: Icons.schedule_rounded, onTap: () => context.push('/settings/hours')),
        SolidButton(
          label: 'پرسنل جدید',
          icon: Icons.person_add_alt_1_rounded,
          height: 42,
          onPressed: () => context.push('/employees/new'),
        ),
      ],
      mobileActions: [
        CircleIconButton(icon: Icons.person_add_alt_1_rounded, size: 38, onTap: () => context.push('/employees/new')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (provider.loading)
            const LoadingState()
          else if (provider.items.isEmpty)
            const EmptyState(title: 'پرسنلی ثبت نشده', description: 'اولین عضو تیم را اضافه کنید.')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final employee in provider.items)
                  SizedBox(
                    width: isDesktop ? 420 : double.infinity,
                    child: EmployeeCard(
                      employee: employee,
                      serviceTitles: services.items
                          .where((s) => employee.serviceIds.contains(s.id))
                          .map((s) => s.title)
                          .toList(),
                      onTap: () => context.push('/employees/${employee.id}'),
                      onEdit: () => context.push('/employees/${employee.id}/edit'),
                      onDelete: () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'حذف پرسنل',
                          message: 'آیا از حذف ${employee.fullName} مطمئن هستید؟',
                          confirmLabel: 'حذف',
                          destructive: true,
                        );
                        if (confirmed && context.mounted) {
                          await provider.remove(employee.id);
                          if (context.mounted) AppToast.show(context, 'پرسنل حذف شد', success: false);
                        }
                      },
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          AppCard(
            color: pal.surfaceAlt.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(Icons.security_rounded, size: 15, color: pal.primaryBright),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'دسترسی هر عضو تیم بر اساس نقش و مجوزهای تعیین‌شده کنترل می‌شود (آماده اتصال به Row Level Security).',
                    style: TextStyle(fontSize: 10.5, color: pal.textMuted, height: 1.7),
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

/// کارت پرسنل با برنامه هفتگی.
class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.employee,
    required this.serviceTitles,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Employee employee;
  final List<String> serviceTitles;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final color = Color(employee.colorValue);
    final workDays = [for (var i = 0; i < 7; i++) if (employee.worksOn(i)) i];

    return AppCard(
      onTap: onTap,
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
                  boxShadow: AppShadows.glow(color, opacity: 0.25, blur: 12),
                ),
                child: Text(
                  employee.initials,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: pal.textPrimary),
                    ),
                    Text(
                      '${employee.title} • ${employee.role.label}',
                      style: TextStyle(fontSize: 10.5, color: pal.textMuted),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 13, color: pal.warning),
              Text(
                FaNum.convert(employee.rating.toStringAsFixed(1)),
                style: TextStyle(fontSize: 10.5, color: pal.textSecondary),
              ),
              const SizedBox(width: 8),
              Icon(Icons.event_available_rounded, size: 13, color: pal.textMuted),
              const SizedBox(width: 3),
              Text(
                '${FaNum.ofInt(employee.bookedCount)} نوبت',
                style: TextStyle(fontSize: 10.5, color: pal.textMuted),
              ),
              const SizedBox(width: 8),
              Icon(Icons.call_outlined, size: 13, color: pal.textMuted),
              const SizedBox(width: 3),
              Text(Fmt.phone(employee.phone), style: TextStyle(fontSize: 10.5, color: pal.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final day in workDays)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: pal.surfaceAlt,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: pal.border),
                  ),
                  child: Text(
                    WeekDay.shortNames[day],
                    style: TextStyle(fontSize: 9.5, color: pal.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          if (serviceTitles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final title in serviceTitles)
                  StatusBadge(label: title, color: pal.primaryBright, dense: true),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: pal.border.withValues(alpha: 0.8), height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              SoftButton(label: 'ویرایش', icon: Icons.edit_rounded, dense: true, onTap: onEdit),
              const SizedBox(width: 8),
              SoftButton(
                label: 'حذف',
                icon: Icons.delete_outline_rounded,
                dense: true,
                color: pal.danger,
                onTap: onDelete,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'مشاهده پروفایل',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: pal.primaryBright, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(Icons.chevron_left_rounded, size: 14, color: pal.primaryBright),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
