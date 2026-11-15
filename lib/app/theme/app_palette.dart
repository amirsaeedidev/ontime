import 'package:flutter/material.dart';

/// پالت رنگی به‌صورت ThemeExtension تا همه ویجت‌ها مستقل از تم به رنگ‌ها دسترسی داشته باشند.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.id,
    required this.label,
    required this.isDark,
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceHigh,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.primaryBright,
    required this.primaryDeep,
    required this.accentGlow,
    required this.success,
    required this.warning,
    required this.danger,
    required this.purple,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.heroGradient,
    required this.successSoft,
    required this.dangerSoft,
    required this.purpleSoft,
  });

  final String id;
  final String label;
  final bool isDark;
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceHigh;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color primaryBright;
  final Color primaryDeep;
  final Color accentGlow;
  final Color success;
  final Color warning;
  final Color danger;
  final Color purple;
  final Color info;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final List<Color> heroGradient;
  final Color successSoft;
  final Color dangerSoft;
  final Color purpleSoft;

  LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primaryBright],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  LinearGradient get heroFill => LinearGradient(
        colors: heroGradient,
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      );

  Color get onPrimary => Colors.white;

  /// پالت اصلی: آبی حرفه‌ای ONTIME (تصویر مرجع پیشخوان).
  static const AppPalette navy = AppPalette(
    id: 'navy',
    label: 'آبی حرفه‌ای',
    isDark: true,
    background: Color(0xFF0A1227),
    backgroundAlt: Color(0xFF101729),
    surface: Color(0xFF111A2B),
    surfaceAlt: Color(0xFF16203A),
    surfaceHigh: Color(0xFF1C2A4A),
    border: Color(0xFF1E2A47),
    borderStrong: Color(0xFF2A3A5F),
    primary: Color(0xFF2563EB),
    primaryBright: Color(0xFF38BDF8),
    primaryDeep: Color(0xFF1D4ED8),
    accentGlow: Color(0xFF00E5FF),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    purple: Color(0xFF8B5CF6),
    info: Color(0xFF3B82F6),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9FB0C9),
    textMuted: Color(0xFF6B7C99),
    heroGradient: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF4FC3F7)],
    successSoft: Color(0xFF0B2033),
    dangerSoft: Color(0xFF2A1522),
    purpleSoft: Color(0xFF1E1738),
  );

  /// پالت گرافیتی/زمردی (تصاویر مرجع ثبت نوبت، مشتریان، خدمات).
  static const AppPalette emerald = AppPalette(
    id: 'emerald',
    label: 'گرافیتی زمردی',
    isDark: true,
    background: Color(0xFF1E222B),
    backgroundAlt: Color(0xFF191D26),
    surface: Color(0xFF1A1E27),
    surfaceAlt: Color(0xFF31343B),
    surfaceHigh: Color(0xFF3A3D45),
    border: Color(0xFF31343B),
    borderStrong: Color(0xFF454952),
    primary: Color(0xFF00B175),
    primaryBright: Color(0xFF10D68E),
    primaryDeep: Color(0xFF00905F),
    accentGlow: Color(0xFF34D399),
    success: Color(0xFF00B175),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    purple: Color(0xFFA21CFA),
    info: Color(0xFF2563EB),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA9AFB8),
    textMuted: Color(0xFF7A828E),
    heroGradient: [Color(0xFF00B175), Color(0xFF10D68E), Color(0xFF34D399)],
    successSoft: Color(0xFF13292A),
    dangerSoft: Color(0xFF2A1418),
    purpleSoft: Color(0xFF241634),
  );

  /// پالت روشن (گزینه ظاهری).
  static const AppPalette light = AppPalette(
    id: 'light',
    label: 'روشن',
    isDark: false,
    background: Color(0xFFF4F7FC),
    backgroundAlt: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F5FB),
    surfaceHigh: Color(0xFFE8EFFA),
    border: Color(0xFFE2E8F0),
    borderStrong: Color(0xFFCBD5E1),
    primary: Color(0xFF2563EB),
    primaryBright: Color(0xFF3B82F6),
    primaryDeep: Color(0xFF1D4ED8),
    accentGlow: Color(0xFF0891B2),
    success: Color(0xFF059669),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
    purple: Color(0xFF7C3AED),
    info: Color(0xFF2563EB),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    heroGradient: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
    successSoft: Color(0xFFECFDF5),
    dangerSoft: Color(0xFFFEF2F2),
    purpleSoft: Color(0xFFF5F3FF),
  );

  static const List<AppPalette> all = [navy, emerald, light];

  static AppPalette byId(String id) => all.firstWhere((p) => p.id == id, orElse: () => navy);

  @override
  AppPalette copyWith({
    String? id,
    String? label,
    bool? isDark,
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceHigh,
    Color? border,
    Color? borderStrong,
    Color? primary,
    Color? primaryBright,
    Color? primaryDeep,
    Color? accentGlow,
    Color? success,
    Color? warning,
    Color? danger,
    Color? purple,
    Color? info,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    List<Color>? heroGradient,
    Color? successSoft,
    Color? dangerSoft,
    Color? purpleSoft,
  }) {
    return AppPalette(
      id: id ?? this.id,
      label: label ?? this.label,
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      primary: primary ?? this.primary,
      primaryBright: primaryBright ?? this.primaryBright,
      primaryDeep: primaryDeep ?? this.primaryDeep,
      accentGlow: accentGlow ?? this.accentGlow,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      purple: purple ?? this.purple,
      info: info ?? this.info,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      heroGradient: heroGradient ?? this.heroGradient,
      successSoft: successSoft ?? this.successSoft,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      purpleSoft: purpleSoft ?? this.purpleSoft,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      id: t < 0.5 ? id : other.id,
      label: t < 0.5 ? label : other.label,
      isDark: t < 0.5 ? isDark : other.isDark,
      background: c(background, other.background),
      backgroundAlt: c(backgroundAlt, other.backgroundAlt),
      surface: c(surface, other.surface),
      surfaceAlt: c(surfaceAlt, other.surfaceAlt),
      surfaceHigh: c(surfaceHigh, other.surfaceHigh),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      primary: c(primary, other.primary),
      primaryBright: c(primaryBright, other.primaryBright),
      primaryDeep: c(primaryDeep, other.primaryDeep),
      accentGlow: c(accentGlow, other.accentGlow),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      danger: c(danger, other.danger),
      purple: c(purple, other.purple),
      info: c(info, other.info),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textMuted: c(textMuted, other.textMuted),
      heroGradient: [c(heroGradient.first, other.heroGradient.first), c(heroGradient.last, other.heroGradient.last)],
      successSoft: c(successSoft, other.successSoft),
      dangerSoft: c(dangerSoft, other.dangerSoft),
      purpleSoft: c(purpleSoft, other.purpleSoft),
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get pal => Theme.of(this).extension<AppPalette>() ?? AppPalette.navy;
}
