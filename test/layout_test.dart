import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ontime/app/app.dart';
import 'package:ontime/app/theme/app_palette.dart';
import 'package:ontime/app/theme/app_theme.dart';
import 'package:ontime/data/mock/app_database.dart';
import 'package:ontime/data/repositories/activity_repository.dart';
import 'package:ontime/data/repositories/appointment_repository.dart';
import 'package:ontime/data/repositories/customer_repository.dart';
import 'package:ontime/data/repositories/dashboard_repository.dart';
import 'package:ontime/data/repositories/employee_repository.dart';
import 'package:ontime/data/repositories/service_repository.dart';
import 'package:ontime/data/repositories/settings_repository.dart';
import 'package:ontime/data/repositories/sms_repository.dart';
import 'package:ontime/features/activity_logs/presentation/providers/activity_provider.dart';
import 'package:ontime/features/appointments/presentation/providers/appointments_provider.dart';
import 'package:ontime/features/booking/presentation/providers/booking_provider.dart';
import 'package:ontime/features/calendar/presentation/providers/calendar_provider.dart';
import 'package:ontime/features/customers/presentation/providers/customers_provider.dart';
import 'package:ontime/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:ontime/features/employees/presentation/providers/employees_provider.dart';
import 'package:ontime/features/reports/presentation/providers/reports_provider.dart';
import 'package:ontime/features/services/presentation/providers/services_provider.dart';
import 'package:ontime/features/settings/presentation/providers/settings_provider.dart';
import 'package:ontime/features/sms/presentation/providers/sms_provider.dart';

/// همهٔ مسیرهای برنامه؛ برای اطمینان از اینکه قلم جدید (لاله‌زار) هیچ
/// سرریز/بریدگی چیدمانی در هیچ صفحه‌ای ایجاد نکرده است.
const _routes = <String>[
  '/dashboard',
  '/appointments',
  '/appointments/new',
  '/customers',
  '/customers/new',
  '/services',
  '/services/new',
  '/employees',
  '/employees/new',
  '/calendar',
  '/sms',
  '/sms/settings',
  '/sms/templates',
  '/reports',
  '/activity',
  '/settings',
  '/settings/business',
  '/settings/hours',
  '/settings/rules',
  '/settings/location',
  '/settings/appearance',
  '/settings/permissions',
  '/settings/notifications',
  '/settings/link',
  '/book',
  '/book/manage',
];

Widget _harness(String route) {
  SharedPreferences.setMockInitialValues({});
  final db = AppDatabase();
  final appointments = MockAppointmentRepository(db);
  final customers = MockCustomerRepository(db);
  final services = MockServiceRepository(db);
  final employees = MockEmployeeRepository(db);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppDatabase> .value(value: db),
      ChangeNotifierProvider(create: (_) => SettingsProvider(MockSettingsRepository(db), db)),
      ChangeNotifierProvider(create: (_) => DashboardProvider(MockDashboardRepository(db), db)),
      ChangeNotifierProvider(create: (_) => AppointmentsProvider(appointments, db)),
      ChangeNotifierProvider(create: (_) => CalendarProvider(appointments, employees, services, db)),
      ChangeNotifierProvider(create: (_) => CustomersProvider(customers, db)),
      ChangeNotifierProvider(create: (_) => ServicesProvider(services, db)),
      ChangeNotifierProvider(create: (_) => EmployeesProvider(employees, db)),
      ChangeNotifierProvider(create: (_) => SmsProvider(MockSmsRepository(db), db)),
      ChangeNotifierProvider(create: (_) => ReportsProvider(MockDashboardRepository(db), db)),
      ChangeNotifierProvider(create: (_) => ActivityProvider(MockActivityRepository(db), db)),
      ChangeNotifierProvider(create: (_) => BookingProvider(appointments, services, employees, customers, db)),
    ],
    child: OnTimeApp(initialLocation: route),
  );
}

void main() {
  testWidgets('قلم سراسری Lalezar است و هیچ‌جا به فونت پیش‌فرض برنمی‌گردد', (tester) async {
    expect(AppTheme.fontFamily, 'Lalezar');
    final theme = AppTheme.build(AppPalette.navy);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Lalezar');
    expect(theme.textTheme.headlineSmall?.fontFamily, 'Lalezar');
    expect(theme.primaryTextTheme.bodyMedium?.fontFamily, 'Lalezar');
  });

  const viewports = <String, Size>{
    'mobile': Size(390, 844),
    'tablet': Size(768, 1024),
    'desktop': Size(1366, 768),
  };

  for (final entry in viewports.entries) {
    for (final route in _routes) {
      testWidgets('${entry.key} $route بدون سرریز چیدمان', (tester) async {
        tester.view.physicalSize = entry.value * 1.0;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final errors = <FlutterErrorDetails>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (details) {
          errors.add(details);
          previous?.call(details);
        };
        addTearDown(() => FlutterError.onError = previous);

        await tester.pumpWidget(_harness(route));
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }

        for (final e in errors) {
          final text = e.toString();
          if (text.contains('overflowed')) {
            final loc = RegExp(r'file:///home/user/ontime/(lib/[^\s]+)').firstMatch(text);
            final size = RegExp(r'overflowed by ([0-9.]+) pixels on the (\w+)').firstMatch(text);
            // ignore: avoid_print
            print('OVERFLOW ${entry.key} $route :: '
                '${loc?.group(1) ?? '?'} :: +${size?.group(1)}px ${size?.group(2)}');
          }
        }
        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason: 'صفحه $route در اندازه ${entry.key} خطا/سرریز داشت: $exception',
        );
      });
    }
  }
}
