import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/theme/app_palette.dart';
import 'app/theme/app_theme.dart';
import 'core/widgets/boot_error_widget.dart';
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

  // ویجت خطا: هیچ وابستگی‌ای به Directionality/MaterialApp ندارد تا خودش خطا
  // ندهد و باعث «بازگشت بی‌پایان → Stack Overflow» نشود.
  ErrorWidget.builder = _buildErrorWidget;

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _logError('FlutterError', details.exceptionAsString());
  };

  runZonedGuarded(
    () {
      // خطاهای غیرمنتظرهٔ پلتفرم (مثلاً پلاگین‌ها) نباید برنامه را متوقف کنند.
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        _logError('PlatformError', '$error');
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
      _logError('ZoneError', '$error');
      _reportFatal(error, stack);
      runApp(_FatalApp(error: error));
    },
  );
}

// ───────────────────────────── مدیریت خطا ─────────────────────────────

/// محدودکنندهٔ طوفان خطا: اگر در بازهٔ کوتاه خطاهای زیادی رخ دهد (نشانهٔ حلقه)،
/// پس از [maxErrorsPerWindow] مورد، به‌جای ساخت ویجت خطا یک ویجت خالی برمی‌گردانیم
/// تا فریم‌ورک هرگز با Stack Overflow از کار نیفتد.
const int maxErrorsPerWindow = 12;
const Duration errorWindow = Duration(seconds: 3);

int _errorCount = 0;
DateTime _errorWindowStart = DateTime.now();

Widget _buildErrorWidget(FlutterErrorDetails details) {
  final now = DateTime.now();
  if (now.difference(_errorWindowStart) > errorWindow) {
    _errorWindowStart = now;
    _errorCount = 0;
  }
  _errorCount++;
  if (_errorCount > maxErrorsPerWindow) {
    // چرخهٔ خطا تشخیص داده شد؛ سکوت امن بهتر از Stack Overflow است.
    return const SizedBox.shrink();
  }
  return BootErrorWidget(
    title: 'خطا در نمایش این بخش',
    details: details.exceptionAsString(),
    compact: true,
  );
}

String? _lastLogged;
int _lastLoggedRepeat = 0;

/// لاگ خطا با حذف تکرارهای پشت‌سرهم تا کنسول با هزاران سطر پر نشود.
void _logError(String source, String message) {
  if (_lastLogged == message) {
    _lastLoggedRepeat++;
    // هر ۲۰ تکرار یک‌بار اعلام می‌کنیم که خطا تکرار شده است.
    if (_lastLoggedRepeat % 20 != 0) return;
    debugPrint('[ONTIME][$source] $message  (تکرار $_lastLoggedRepeat)');
    return;
  }
  _lastLogged = message;
  _lastLoggedRepeat = 0;
  debugPrint('[ONTIME][$source] $message');
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
///
/// این صفحه خودش از [BootErrorWidget] استفاده می‌کند که هیچ وابستگی به محیط
/// ندارد؛ بنابراین حتی اگر ساخت برنامه نیمه‌کاره بماند، نمایش خطا امن است.
class _FatalApp extends StatelessWidget {
  const _FatalApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(AppPalette.navy),
      home: ColoredBox(
        color: const Color(0xFF0A1227),
        child: BootErrorWidget(
          title: 'اجرای برنامه با خطا مواجه شد',
          details: '$error',
          compact: false,
        ),
      ),
    );
  }
}
