import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../features/settings/presentation/providers/settings_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// ریشه برنامه با پشتیبانی کامل RTL و تم پویا.
class OnTimeApp extends StatefulWidget {
  const OnTimeApp({super.key, this.initialLocation = '/dashboard'});

  /// فقط برای تست‌های چیدمان؛ در اجرای عادی پیشخوان است.
  final String initialLocation;

  @override
  State<OnTimeApp> createState() => _OnTimeAppState();
}

class _OnTimeAppState extends State<OnTimeApp> {
  late final _router = buildRouter(initialLocation: widget.initialLocation);

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<SettingsProvider>().palette;
    final theme = AppTheme.build(palette);
    return MaterialApp.router(
      title: 'ONTIME — مدیریت نوبت‌دهی',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      // هر دو تم روشن/تیره با همان قلم ساخته می‌شوند تا حتی اگر حالت نمایش
      // سیستم تغییر کند، هیچ متنی به قلم پیش‌فرض برنگردد.
      theme: theme,
      darkTheme: theme,
      themeMode: palette.isDark ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          // شبکه ایمنی: هر Text بدون استایل اختصاصی هم با Lalezar رندر می‌شود.
          child: DefaultTextStyle(
            style: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
              fontFamily: AppTheme.fontFamily,
              color: palette.textPrimary,
            ),
            child: MediaQuery.withClampedTextScaling(
              minScaleFactor: 1,
              maxScaleFactor: 1.2,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
