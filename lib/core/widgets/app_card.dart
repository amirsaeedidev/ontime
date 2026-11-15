import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../../core/utils/fa_num.dart';

/// کارت پایه با گوشه‌های گرد، حاشیه نازک و امکان نوار رنگی کناری (RTL: سمت راست).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.gradient,
    this.borderColor,
    this.radius = AppRadius.lg,
    this.accentColor,
    this.accentWidth = 4,
    this.onTap,
    this.glow,
    this.minHeight,
  });

  final Widget? child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;
  final Color? accentColor;
  final double accentWidth;
  final VoidCallback? onTap;
  final Color? glow;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          if (accentColor != null)
            PositionedDirectional(
              top: 0,
              bottom: 0,
              start: 0,
              child: Container(width: accentWidth, color: accentColor),
            ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );

    return Container(
      margin: margin,
      constraints: minHeight == null ? null : BoxConstraints(minHeight: minHeight!),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? pal.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? pal.border),
        boxShadow: glow == null ? null : AppShadows.glow(glow!, opacity: 0.22, blur: 26),
      ),
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: onTap,
                child: content,
              ),
            ),
    );
  }
}

/// سرتیتر بخش با نشانگر رنگی و دکمه اقدام.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.accent,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accent;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accent ?? pal.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        // Flexible (نه Expanded) تا اگر SectionHeader داخل یک Row بدون عرض
        // محدود قرار گرفت، خطای «non-zero flex with unbounded constraints» رخ ندهد.
        Flexible(
          fit: FlexFit.loose,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: pal.textPrimary,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: TextStyle(fontSize: 11.5, color: pal.textMuted),
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
        if (actionLabel != null)
          InkWell(
            borderRadius: AppRadius.brSm,
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Icon(Icons.chevron_left_rounded, size: 16, color: pal.textMuted),
                  const SizedBox(width: 2),
                  Text(
                    actionLabel!,
                    style: TextStyle(fontSize: 11.5, color: pal.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// کارت آماری کوچک با آیکون (مانند «تکمیل شده» و «درآمد تخمینی»).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.tint,
    this.background,
    this.borderColor,
    this.compact = false,
    this.onTap,
    this.valueSize,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? tint;
  final Color? background;
  final Color? borderColor;
  final bool compact;
  final VoidCallback? onTap;
  final double? valueSize;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final color = tint ?? pal.primaryBright;
    return AppCard(
      onTap: onTap,
      color: background ?? pal.surface,
      borderColor: borderColor ?? pal.border,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 12 : 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11.5, color: pal.textSecondary, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize ?? (compact ? 14 : 16),
                    fontWeight: FontWeight.w800,
                    color: pal.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: compact ? 34 : 40,
            height: compact ? 34 : 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: compact ? 17 : 19, color: color),
          ),
        ],
      ),
    );
  }
}

/// ردیف اطلاعات (برچسب / مقدار).
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.dense = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 5 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: pal.textMuted),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(fontSize: 12, color: pal.textMuted)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: dense ? 12 : 12.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? pal.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// نشانگر عددی کوچک (مثل تعداد پیامک).
class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.value, this.icon, this.color});

  final int value;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final c = color ?? pal.primaryBright;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: AppRadius.brPill,
        border: Border.all(color: c.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            FaNum.ofInt(value),
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c),
          ),
        ],
      ),
    );
  }
}
