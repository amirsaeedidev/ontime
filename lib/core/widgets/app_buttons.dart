import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';

/// دکمه اصلی گرادیانی (CTA) با آیکون دایره‌ای و زیرعنوان — مطابق تصویر مرجع پیشخوان.
class GradientCta extends StatelessWidget {
  const GradientCta({
    super.key,
    required this.title,
    required this.onPressed,
    this.subtitle,
    this.icon = Icons.add_rounded,
    this.height = 78,
    this.gradient,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onPressed;
  final double height;
  final Gradient? gradient;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final grad = gradient ?? pal.heroFill;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.glow(pal.primary, opacity: 0.28, blur: 30),
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            gradient: grad,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20),
              child: Row(
                children: [
                  Container(
                    width: compact ? 38 : 46,
                    height: compact ? 38 : 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
                    ),
                    child: Icon(icon, color: Colors.white, size: compact ? 20 : 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 14 : 16,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: compact ? 10.5 : 11.5,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// دکمه دایره‌ای آیکونی برای نوار بالا.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.badge = false,
    this.active = false,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool badge;
  final bool active;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final tint = color ?? pal.textPrimary;
    final content = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? pal.primary.withValues(alpha: 0.18) : pal.surfaceAlt,
            border: Border.all(color: active ? pal.primary.withValues(alpha: 0.5) : pal.borderStrong),
          ),
          child: Icon(icon, size: size * 0.46, color: active ? pal.primaryBright : tint),
        ),
        if (badge)
          PositionedDirectional(
            top: size * 0.14,
            end: size * 0.16,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: pal.primaryBright,
                shape: BoxShape.circle,
                boxShadow: AppShadows.glow(pal.primaryBright, opacity: 0.8, blur: 8),
              ),
            ),
          ),
      ],
    );
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}

/// دکمه نرم (پس‌زمینه ملایم) برای اقدامات ثانویه.
class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.color,
    this.dense = false,
    this.expanded = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool dense;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final c = color ?? pal.textPrimary;
    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 14, vertical: dense ? 7 : 10),
      decoration: BoxDecoration(
        color: pal.surfaceAlt,
        borderRadius: BorderRadius.circular(dense ? AppRadius.sm : AppRadius.md),
        border: Border.all(color: pal.border),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 14 : 16, color: c),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: dense ? 11.5 : 12.5,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// دکمه تمام‌عرض با پس‌زمینه رنگی.
class SolidButton extends StatelessWidget {
  const SolidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.height = 50,
    this.loading = false,
    this.gradient = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double height;
  final bool loading;
  final bool gradient;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final c = color ?? pal.primary;
    if (outlined) {
      return SizedBox(
        height: height,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          child: _label(pal.textPrimary),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ? LinearGradient(colors: [c, Color.lerp(c, Colors.white, 0.22)!]) : null,
          color: gradient ? null : c,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.glow(c, opacity: 0.25, blur: 18),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: loading ? null : onPressed,
            child: Center(child: _label(Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _label(Color color) {
    if (loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// کلید انتخاب دوگانه (هفتگی / ماهانه).
class PillToggle extends StatelessWidget {
  const PillToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.dense = false,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: pal.surfaceAlt,
        borderRadius: AppRadius.brPill,
        border: Border.all(color: pal.border),
      ),
      // FittedBox تضمین می‌کند برچسب‌های فارسی (که با قلم لاله‌زار عریض‌ترند)
      // در عرض‌های کم بدون سرریز، کمی کوچک‌تر شوند.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: EdgeInsets.symmetric(horizontal: dense ? 9 : 13, vertical: dense ? 4 : 6),
                decoration: BoxDecoration(
                  color: i == selectedIndex ? pal.primary : Colors.transparent,
                  borderRadius: AppRadius.brPill,
                ),
                child: Text(
                  options[i],
                  style: TextStyle(
                    fontSize: dense ? 11 : 12,
                    fontWeight: i == selectedIndex ? FontWeight.w700 : FontWeight.w500,
                    color: i == selectedIndex ? Colors.white : pal.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

/// برچسب روند (مثلاً +۱۲٪).
class TrendChip extends StatelessWidget {
  const TrendChip({super.key, required this.value, this.positive = true, this.icon});

  final String value;
  final bool positive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final c = positive ? pal.success : pal.danger;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c),
        ),
        const SizedBox(width: 2),
        Icon(icon ?? (positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded), size: 13, color: c),
      ],
    );
  }
}
