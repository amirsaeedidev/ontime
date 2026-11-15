import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../core/responsive/app_shell.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/badges.dart';
import '../../features/activity_logs/presentation/pages/activity_logs_page.dart';
import '../../features/appointments/presentation/pages/appointment_details_page.dart';
import '../../features/appointments/presentation/pages/appointment_form_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/booking/presentation/pages/booking_flow_page.dart';
import '../../features/booking/presentation/pages/booking_manage_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/customers/presentation/pages/customer_form_page.dart';
import '../../features/customers/presentation/pages/customer_profile_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/employees/presentation/pages/employee_form_page.dart';
import '../../features/employees/presentation/pages/employee_profile_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/services/presentation/pages/service_form_page.dart';
import '../../features/services/presentation/pages/services_page.dart';
import '../../features/settings/presentation/pages/advanced_settings_page.dart';
import '../../features/settings/presentation/pages/appearance_settings_page.dart';
import '../../features/settings/presentation/pages/booking_rules_page.dart';
import '../../features/settings/presentation/pages/business_settings_page.dart';
import '../../features/settings/presentation/pages/location_settings_page.dart';
import '../../features/settings/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/permissions_page.dart';
import '../../features/settings/presentation/pages/public_link_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/sms/presentation/pages/sms_monitor_page.dart';
import '../../features/sms/presentation/pages/sms_settings_page.dart';
import '../../features/sms/presentation/pages/sms_templates_page.dart';

/// مسیرهای برنامه؛ ناوبری مستقل از منطق کسب‌وکار.
///
/// [initialLocation] تنها برای تست‌های چیدمان استفاده می‌شود؛ در اجرای واقعی
/// همیشه از پیشخوان شروع می‌کنیم.
GoRouter buildRouter({String initialLocation = '/dashboard'}) {
  // کلید ناوبری برای هر نمونه از روتر مستقل است تا ساخت دوبارهٔ برنامه
  // (مثلاً در تست‌ها یا hot restart) باعث تداخل GlobalKey نشود.
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/dashboard', pageBuilder: (context, state) => const NoTransitionPage(child: DashboardPage())),
          GoRoute(
            path: '/appointments',
            pageBuilder: (context, state) => const NoTransitionPage(child: AppointmentsPage()),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const AppointmentFormPage()),
              GoRoute(
                path: ':id',
                builder: (context, state) => AppointmentDetailsPage(appointmentId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => AppointmentFormPage(appointmentId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(path: '/calendar', pageBuilder: (context, state) => const NoTransitionPage(child: CalendarPage())),
          GoRoute(
            path: '/customers',
            pageBuilder: (context, state) => const NoTransitionPage(child: CustomersPage()),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const CustomerFormPage()),
              GoRoute(
                path: ':id',
                builder: (context, state) => CustomerProfilePage(customerId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => CustomerFormPage(customerId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/services',
            pageBuilder: (context, state) => const NoTransitionPage(child: ServicesPage()),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const ServiceFormPage()),
              GoRoute(
                path: ':id/edit',
                builder: (context, state) => ServiceFormPage(serviceId: state.pathParameters['id']),
              ),
            ],
          ),
          GoRoute(
            path: '/employees',
            pageBuilder: (context, state) => const NoTransitionPage(child: EmployeesPage()),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const EmployeeFormPage()),
              GoRoute(
                path: ':id',
                builder: (context, state) => EmployeeProfilePage(employeeId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => EmployeeFormPage(employeeId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/sms',
            pageBuilder: (context, state) => const NoTransitionPage(child: SmsMonitorPage()),
            routes: [
              GoRoute(path: 'settings', builder: (context, state) => const SmsSettingsPage()),
              GoRoute(path: 'templates', builder: (context, state) => const SmsTemplatesPage()),
            ],
          ),
          GoRoute(path: '/reports', pageBuilder: (context, state) => const NoTransitionPage(child: ReportsPage())),
          GoRoute(path: '/activity', pageBuilder: (context, state) => const NoTransitionPage(child: ActivityLogsPage())),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
            routes: [
              GoRoute(path: 'business', builder: (context, state) => const BusinessSettingsPage()),
              GoRoute(path: 'hours', builder: (context, state) => const AdvancedSettingsPage()),
              GoRoute(path: 'rules', builder: (context, state) => const BookingRulesPage()),
              GoRoute(path: 'location', builder: (context, state) => const LocationSettingsPage()),
              GoRoute(path: 'appearance', builder: (context, state) => const AppearanceSettingsPage()),
              GoRoute(path: 'permissions', builder: (context, state) => const PermissionsPage()),
              GoRoute(path: 'notifications', builder: (context, state) => const NotificationsPage()),
              GoRoute(path: 'link', builder: (context, state) => const PublicLinkPage()),
            ],
          ),
        ],
      ),
      // تجربه مشتری (بدون پوسته مدیریتی)
      GoRoute(path: '/book', builder: (context, state) => const BookingFlowPage()),
      GoRoute(path: '/book/manage', builder: (context, state) => const BookingManagePage()),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: context.pal.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTile(icon: Icons.search_off_rounded, color: context.pal.primaryBright, size: 66, radius: 22),
              const SizedBox(height: 18),
              Text(
                'صفحه مورد نظر یافت نشد',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: context.pal.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'آدرس «${state.uri.path}» در سامانه وجود ندارد.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: context.pal.textMuted),
              ),
              const SizedBox(height: 20),
              SolidButton(
                label: 'بازگشت به پیشخوان',
                icon: Icons.dashboard_rounded,
                gradient: true,
                onPressed: () => context.go('/dashboard'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
