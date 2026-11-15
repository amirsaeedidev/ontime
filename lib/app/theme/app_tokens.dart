import 'package:flutter/widgets.dart';

/// واحدهای پایه طراحی (چیدمان، شعاع گوشه و اندازه‌ها).
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// حاشیه افقی صفحه بر اساس عرض.
  static double pagePadding(double width) {
    if (width >= 1440) return 32;
    if (width >= 1024) return 28;
    if (width >= 600) return 24;
    return 16;
  }
}

class AppRadius {
  const AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 22;
  static const double xxl = 26;
  static const double pill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));

  static BorderRadius brTopXxl = const BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
}

class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);
}

/// نقاط شکست واکنش‌گرا.
class Breakpoints {
  const Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double large = 1600;

  static bool isMobile(double w) => w < mobile;
  static bool isTablet(double w) => w >= mobile && w < desktop;
  static bool isDesktop(double w) => w >= desktop;

  /// حداکثر عرض محتوای صفحه برای خوانایی روی نمایشگرهای بزرگ.
  static double contentMaxWidth(double w) {
    if (w >= 1920) return 1500;
    if (w >= 1440) return 1320;
    return double.infinity;
  }
}

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> soft(Color color, {double blur = 24, double y = 8, double opacity = 0.18}) => [
        BoxShadow(color: color.withValues(alpha: opacity), blurRadius: blur, offset: Offset(0, y)),
      ];

  static List<BoxShadow> glow(Color color, {double blur = 18, double opacity = 0.45}) => [
        BoxShadow(color: color.withValues(alpha: opacity), blurRadius: blur, spreadRadius: 1),
      ];
}
