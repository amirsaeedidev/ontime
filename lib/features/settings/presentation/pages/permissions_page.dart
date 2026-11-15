import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/enums.dart';
import '../../../employees/presentation/providers/employees_provider.dart';

/// مدیریت نقش‌ها و دسترسی‌ها (آماده برای Supabase RLS).
class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  static const _modules = {
    'dashboard': 'پیشخوان',
    'appointments': 'نوبت‌ها',
    'customers': 'مشتریان',
    'services': 'خدمات',
    'employees': 'پرسنل',
    'sms': 'پیامک',
    'reports': 'گزارش‌ها',
    'settings': 'تنظیمات',
  };

  @override
  Widget build(BuildContext context) {
    final employees = context.watch<EmployeesProvider>();
    final pal = context.pal;

    return PageScaffold(
      title: 'دسترسی‌ها و نقش‌ها',
      subtitle: 'کنترل مجوزهای پرسنل',
      icon: Icons.security_rounded,
      showBackButton: true,
      actions: [
        SoftButton(label: 'مدیریت پرسنل', icon: Icons.badge_rounded, onTap: () => AppToast.show(context, 'از بخش پرسنل قابل ویرایش است')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'نقش‌های تعریف‌شده'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final role in StaffRole.values)
                      StatusBadge(
                        label: role.label,
                        color: role == StaffRole.owner ? pal.primaryBright : pal.textSecondary,
                        icon: role == StaffRole.owner ? Icons.star_rounded : null,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final employee in employees.items) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AvatarBadge(name: employee.fullName, size: 38, color: pal.primaryBright),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.fullName,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: pal.textPrimary),
                            ),
                            Text(employee.role.label, style: TextStyle(fontSize: 10, color: pal.textMuted)),
                          ],
                        ),
                      ),
                      StatusBadge(
                        label: '${FaNum.ofInt(employee.permissions.length)} دسترسی',
                        color: pal.success,
                        dense: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final entry in _modules.entries)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: employee.permissions.contains(entry.key)
                                ? pal.primary.withValues(alpha: 0.14)
                                : pal.surfaceAlt,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: employee.permissions.contains(entry.key)
                                  ? pal.primary.withValues(alpha: 0.45)
                                  : pal.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                employee.permissions.contains(entry.key)
                                    ? Icons.check_circle_rounded
                                    : Icons.remove_circle_outline_rounded,
                                size: 11,
                                color: employee.permissions.contains(entry.key) ? pal.primaryBright : pal.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: employee.permissions.contains(entry.key)
                                      ? pal.textPrimary
                                      : pal.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SoftButton(
                      label: 'ویرایش دسترسی',
                      icon: Icons.edit_rounded,
                      dense: true,
                      onTap: () => AppToast.show(context, 'برای ویرایش به پروفایل پرسنل مراجعه کنید'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          AppCard(
            color: pal.surfaceAlt.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(Icons.shield_rounded, size: 15, color: pal.primaryBright),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ساختار مجوزها با Row Level Security در Supabase سازگار است؛ هر نقش فقط به داده‌های مجاز دسترسی خواهد داشت.',
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
