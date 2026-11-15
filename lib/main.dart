import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/theme/app_palette.dart';
import 'app/theme/app_theme.dart';
import 'data/mock/app_database.dart';
import 'data/repositories/activity_repository.dart';
import 'data/repositories/appointment_repository.dart';
import 'data/repositories/customer_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/employee_repository.dart';
import 'data/repositories/service_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/sms_repository.dart';
import 'features/activity_logs/presentation/providers/activity_provider.dart';
import 'features/appointments/presentation/providers/appointments_provider.dart';
import 'features/booking/presentation/providers/booking_provider.dart';
import 'features/calendar/presentation/providers/calendar_provider.dart';
import 'features/customers/presentation/providers/customers_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/employees/presentation/providers/employees_provider.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/services/presentation/providers/services_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/sms/presentation/providers/sms_provider.dart';

/// نقطه ورود برنامه.
///
/// نکته مهم دربارهٔ «صفحه بارگذاری بی‌پایان»: هیچ عملیات ناهمگامِ اضطراری
/// نباید پیش از `runApp` اجرا شود. بنابراین:
///  • `SharedPreferences` پیش از ساخت برنامه خوانده نمی‌شود (به‌صورت تنبل در
///    `SettingsProvider` بارگذاری می‌شود).
///  • تنظیم جهت صفحه «بدون انتظار» انجام می‌شود؛ خطای احتمالی آن راه‌اندازی را
///    متوقف نمی‌کند.
///  • کل راه‌اندازی در `runZonedGuarded` اجرا می‌شود و هر خطای غیرمنتظره به یک
///    صفحه خطای فارسی (با امکان تلاش دوباره) تبدیل می‌شود؛ نه اسپینر ابدی.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // نمایش خطاهای رندر به‌جای صفحه قرمز/خالی.
  ErrorWidget.builder = (FlutterErrorDetails details) => _StartupErrorBox(
        message: 'خطا در نمایش این بخش',
        details: details.exceptionAsString(),
        compact: true,
      );

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[ONTIME][FlutterError] ${details.exceptionAsString()}');
  };

  runZonedGuarded(
    () {
      // خطاهای غیرمنتظرهٔ پلتفرم (مثلاً پلاگین‌ها) نباید برنامه را متوقف کنند.
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        debugPrint('[ONTIME][PlatformError] $error\n$stack');
        return true;
      };

      // غیرمسدودکننده: نتیجهٔ این فراخوانی برای نمایش برنامه لازم نیست.
      unawaited(
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeRight,
        ]).catchError((Object error) {
          debugPrint('[ONTIME] setPreferredOrientations skipped: $error');
        }),
      );

      runApp(const OnTimeBootstrap());
    },
    (Object error, StackTrace stack) {
      debugPrint('[ONTIME][ZoneError] $error\n$stack');
      _reportFatal(error, stack);
      runApp(_FatalApp(error: error));
    },
  );
}

void _reportFatal(Object error, StackTrace stack) {
  // نقطه اتصال برای گزارش‌گیری آینده (Sentry/CRaSH). فعلاً فقط لاگ می‌شود.
  if (kDebugMode) {
    debugPrint('[ONTIME][FATAL] $error');
  }
}

/// ساخت لایه داده و ثبت Providerها.
///
/// همهٔ وابستگی‌ها سنکرون ساخته می‌شوند (بدون Future)، بنابراین هیچ‌گاه
/// راه‌اندازی روی یک Future ناتمام قفل نمی‌شود. خود Providerها داده‌هایشان را
/// به‌صورت غیرهمگام و با مدیریت خطا بارگذاری می‌کنند.
class OnTimeBootstrap extends StatefulWidget {
  const OnTimeBootstrap({super.key});

  @override
  State<OnTimeBootstrap> createState() => _OnTimeBootstrapState();
}

class _OnTimeBootstrapState extends State<OnTimeBootstrap> {
  // در طول عمر برنامه فقط یک‌بار ساخته می‌شوند (rebuild هرگز دوباره نمی‌سازد).
  late final AppDatabase _database = AppDatabase();
  late final AppointmentRepository _appointments = MockAppointmentRepository(_database);
  late final CustomerRepository _customers = MockCustomerRepository(_database);
  late final ServiceRepository _services = MockServiceRepository(_database);
  late final EmployeeRepository _employees = MockEmployeeRepository(_database);
  late final SmsRepository _sms = MockSmsRepository(_database);
  late final SettingsRepository _settings = MockSettingsRepository(_database);
  late final DashboardRepository _dashboard = MockDashboardRepository(_database);
  late final ActivityRepository _activity = MockActivityRepository(_database);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // لایه داده (در این فاز درون‌حافظه‌ای؛ آماده جایگزینی با Supabase).
        Provider<AppDatabase>.value(value: _database),
        Provider<AppointmentRepository>.value(value: _appointments),
        Provider<CustomerRepository>.value(value: _customers),
        Provider<ServiceRepository>.value(value: _services),
        Provider<EmployeeRepository>.value(value: _employees),
        Provider<SmsRepository>.value(value: _sms),
        Provider<SettingsRepository>.value(value: _settings),
        Provider<DashboardRepository>.value(value: _dashboard),
        Provider<ActivityRepository>.value(value: _activity),

        // وضعیت‌های برنامه. ترتیب ثبت مهم نیست چون وابستگی‌ها به‌صورت
        // ارجاع مستقیم به ریپازیتوری‌ها تزریق می‌شوند (بدون چرخه).
        ChangeNotifierProvider(create: (_) => SettingsProvider(_settings, _database)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(_dashboard, _database)),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider(_appointments, _database)),
        ChangeNotifierProvider(
          create: (_) => CalendarProvider(_appointments, _employees, _services, _database),
        ),
        ChangeNotifierProvider(create: (_) => CustomersProvider(_customers, _database)),
        ChangeNotifierProvider(create: (_) => ServicesProvider(_services, _database)),
        ChangeNotifierProvider(create: (_) => EmployeesProvider(_employees, _database)),
        ChangeNotifierProvider(create: (_) => SmsProvider(_sms, _database)),
        ChangeNotifierProvider(create: (_) => ReportsProvider(_dashboard, _database)),
        ChangeNotifierProvider(create: (_) => ActivityProvider(_activity, _database)),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(_appointments, _services, _employees, _customers, _database),
        ),
      ],
      child: const OnTimeApp(),
    );
  }
}

/// صفحه خطای فارسی؛ در صورت شکست فاجعه‌بار راه‌اندازی نمایش داده می‌شود.
class _FatalApp extends StatelessWidget {
  const _FatalApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(AppPalette.navy),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _StartupErrorBox(
                message: 'اجرای برنامه با خطا مواجه شد',
                details: '$error',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupErrorBox extends StatelessWidget {
  const _StartupErrorBox({required this.message, required this.details, this.compact = false});

  final String message;
  final String details;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEF4444);
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFF111A2B),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: AppTheme.fontFamily, color: accent, fontSize: 12),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded, color: accent, size: 44),
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          details.length > 240 ? '${details.substring(0, 240)}…' : details,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 11,
            color: Color(0xFF9FB0C9),
            height: 1.7,
          ),
        ),
      ],
    );
  }
}
