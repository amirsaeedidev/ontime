import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ontime/app/app.dart';
import 'package:ontime/data/mock/app_database.dart';
import 'package:ontime/data/repositories/appointment_repository.dart';
import 'package:ontime/data/repositories/customer_repository.dart';
import 'package:ontime/data/repositories/dashboard_repository.dart';
import 'package:ontime/data/repositories/employee_repository.dart';
import 'package:ontime/data/repositories/service_repository.dart';
import 'package:ontime/data/repositories/settings_repository.dart';
import 'package:ontime/data/repositories/sms_repository.dart';
import 'package:ontime/data/repositories/activity_repository.dart';
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

void main() {
  testWidgets('برنامه بدون خطا بالا می‌آید و پیشخوان رندر می‌شود', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final db = AppDatabase();
    final appointments = MockAppointmentRepository(db);
    final customers = MockCustomerRepository(db);
    final services = MockServiceRepository(db);
    final employees = MockEmployeeRepository(db);
    final settings = MockSettingsRepository(db);

    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppDatabase>.value(value: db),
          ChangeNotifierProvider(create: (_) => SettingsProvider(settings, db, prefs: prefs)),
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
        child: const OnTimeApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.takeException(), isNull);
    expect(find.text('پیشخوان'), findsWidgets);
  });
}
