import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_tokens.dart';

/// ساخت ThemeData بر اساس پالت انتخاب‌شده (Material 3 + تنظیمات اختصاصی).
class AppTheme {
  const AppTheme._();

  /// قلم سراسری برنامه. تنها قلم ثبت‌شده در `pubspec.yaml` است تا هیچ‌جا
  /// به فونت پیش‌فرض (Roboto) برنگردیم.
  static const String fontFamily = 'Lalezar';

  /// لاله‌زار فونت نمایشی با ارتفاع خط بلند است؛ برای جلوگیری از بریدگی
  /// گلیف‌ها، ارتفاع خط پیش‌فرض کمی افزایش داده شده است.
  static const double _lineHeight = 1.85;

  static ThemeData build(AppPalette palette) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: palette.isDark ? Brightness.dark : Brightness.light,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: palette.isDark ? Brightness.dark : Brightness.light,
        primary: palette.primary,
        secondary: palette.purple,
        surface: palette.surface,
        error: palette.danger,
      ),
      scaffoldBackgroundColor: palette.background,
      splashFactory: InkSparkle.splashFactory,
    );

    final text = _textTheme(base, palette);

    return base.copyWith(
      textTheme: text,
      primaryTextTheme: text,
      extensions: [palette],
      dividerColor: palette.border,
      dividerTheme: DividerThemeData(color: palette.border, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: palette.textSecondary, size: 20),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.backgroundAlt,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.textPrimary, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brLg,
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceAlt,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13.5,
          color: palette.textMuted,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(fontFamily: fontFamily, color: palette.textSecondary, fontSize: 13),
        floatingLabelStyle: TextStyle(fontFamily: fontFamily, color: palette.primaryBright, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: palette.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: palette.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: palette.danger, width: 1.4),
        ),
        errorStyle: TextStyle(
          fontFamily: fontFamily,
          color: palette.danger,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w700),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.borderStrong),
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13.5, fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primaryBright,
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceAlt,
        side: BorderSide(color: palette.border),
        labelStyle: TextStyle(fontFamily: fontFamily, fontSize: 12.5, color: palette.textSecondary),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : palette.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? palette.primary : palette.surfaceHigh,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? palette.primary : Colors.transparent,
        ),
        side: BorderSide(color: palette.borderStrong),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13.5,
          color: palette.textSecondary,
          height: 1.7,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brTopXxl),
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceHigh,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: palette.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brMd,
          side: BorderSide(color: palette.border),
        ),
        textStyle: TextStyle(fontFamily: fontFamily, fontSize: 13, color: palette.textPrimary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.surfaceHigh,
          borderRadius: AppRadius.brSm,
        ),
        textStyle: TextStyle(fontFamily: fontFamily, fontSize: 11.5, color: palette.textPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.primary),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textSecondary,
        textColor: palette.textPrimary,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: palette.textPrimary,
        ),
        subtitleTextStyle: TextStyle(fontFamily: fontFamily, fontSize: 12, color: palette.textMuted),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.backgroundAlt,
        selectedItemColor: palette.primaryBright,
        unselectedItemColor: palette.textMuted,
        selectedLabelStyle: const TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        dataTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: palette.textSecondary,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(fontFamily: fontFamily, fontSize: 13, color: palette.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.backgroundAlt,
        indicatorColor: palette.primary.withValues(alpha: 0.16),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ThemeData base, AppPalette palette) {
    TextStyle s(double size, FontWeight weight, {double height = 1.6, Color? color}) => TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: color ?? palette.textPrimary,
        );
    return base.textTheme.copyWith(
      displayLarge: s(34, FontWeight.w800, height: 1.35),
      displayMedium: s(28, FontWeight.w800, height: 1.35),
      displaySmall: s(24, FontWeight.w800, height: 1.4),
      headlineLarge: s(22, FontWeight.w700, height: 1.45),
      headlineMedium: s(20, FontWeight.w700, height: 1.45),
      headlineSmall: s(18, FontWeight.w700, height: 1.5),
      titleLarge: s(16, FontWeight.w700, height: 1.6),
      titleMedium: s(14.5, FontWeight.w600, height: 1.6),
      titleSmall: s(13, FontWeight.w600, height: 1.6),
      bodyLarge: s(14, FontWeight.w400, height: _lineHeight, color: palette.textSecondary),
      bodyMedium: s(13, FontWeight.w400, height: _lineHeight, color: palette.textSecondary),
      bodySmall: s(11.5, FontWeight.w400, height: _lineHeight, color: palette.textMuted),
      labelLarge: s(13, FontWeight.w600, height: 1.7),
      labelMedium: s(12, FontWeight.w500, height: 1.7, color: palette.textSecondary),
      labelSmall: s(10.5, FontWeight.w500, height: 1.7, color: palette.textMuted),
    );
  }
}
