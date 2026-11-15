import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../../data/models/enums.dart';

/// برچسب وضعیت (تأیید شده، در انتظار، ...) با رنگ مرتبط.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dense = false,
    this.filled = false,
  });

  factory StatusBadge.appointment(AppointmentStatus status, {bool dense = false}) =>
      StatusBadge(label: status.label, color: status.color, dense: dense);

  factory StatusBadge.sms(SmsStatus status, {bool dense = false}) =>
      StatusBadge(label: status.label, color: status.color, dense: dense, icon: status == SmsStatus.failed ? Icons.error_outline_rounded : null);

  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 11, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: pal.isDark ? 0.15 : 0.12),
        borderRadius: AppRadius.brPill,
        border: Border.all(color: color.withValues(alpha: filled ? 1 : 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 10 : 12, color: filled ? Colors.white : color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}

/// آواتار دایره‌ای با حرف اول نام.
class AvatarBadge extends StatelessWidget {
  const AvatarBadge({
    super.key,
    required this.name,
    this.color,
    this.size = 46,
    this.icon,
    this.filled = true,
    this.imageUrl,
  });

  final String name;
  final Color? color;
  final double size;
  final IconData? icon;
  final bool filled;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final tint = color ?? pal.primary;
    final initial = name.trim().isEmpty ? '؟' : String.fromCharCode(name.trim().runes.first);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? tint.withValues(alpha: 0.18) : tint,
        border: Border.all(color: tint.withValues(alpha: 0.45)),
      ),
      child: icon != null
          ? Icon(icon, size: size * 0.44, color: filled ? tint : Colors.white)
          : Text(
              initial,
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w700,
                color: filled ? tint : Colors.white,
                height: 1.1,
              ),
            ),
    );
  }
}

/// آیکون داخل جعبه گرد (مورد استفاده در کارت خدمات و آماری‌ها).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.color,
    this.size = 44,
    this.radius = 14,
    this.filled = false,
  });

  final IconData icon;
  final Color? color;
  final double size;
  final double radius;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final tint = color ?? pal.primaryBright;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: filled ? 0.9 : 0.14),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: tint.withValues(alpha: 0.28)),
      ),
      child: Icon(icon, size: size * 0.44, color: filled ? Colors.white : tint),
    );
  }
}

/// برچسب کوچک اطلاعات (مثل «فعال»).
class TinyTag extends StatelessWidget {
  const TinyTag({super.key, required this.label, this.color, this.icon});

  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return StatusBadge(label: label, color: color ?? context.pal.success, icon: icon, dense: true);
  }
}
