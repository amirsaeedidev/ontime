import 'package:flutter/material.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';

/// حالت خالی با آیکون و توضیح.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title = 'موردی یافت نشد',
    this.description = 'فیلترها را تغییر دهید یا داده جدیدی ثبت کنید.',
    this.icon = Icons.inbox_rounded,
    this.action,
    this.compact = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 24 : 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 56 : 72,
              height: compact ? 56 : 72,
              decoration: BoxDecoration(
                color: pal.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: pal.border),
              ),
              child: Icon(icon, size: compact ? 26 : 32, color: pal.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: pal.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: pal.textMuted, height: 1.7),
            ),
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// حالت بارگذاری.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'در حال دریافت اطلاعات...', this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 24 : 56),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: pal.primaryBright),
            ),
            const SizedBox(height: 14),
            Text(label, style: TextStyle(fontSize: 12, color: pal.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// حالت خطا با امکان تلاش مجدد.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    this.title = 'خطا در دریافت اطلاعات',
    this.description = 'اتصال خود را بررسی کنید و دوباره تلاش کنید.',
    this.onRetry,
  });

  final String title;
  final String description;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 34, color: pal.danger),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: pal.textPrimary)),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: pal.textMuted, height: 1.7),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('تلاش مجدد'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// نمایش پیام کوتاه (SnackBar) با استایل اپلیکیشن.
class AppToast {
  const AppToast._();

  static void show(BuildContext context, String message, {bool success = true, IconData? icon}) {
    final pal = context.pal;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          backgroundColor: pal.surfaceHigh,
          content: Row(
            children: [
              Icon(
                icon ?? (success ? Icons.check_circle_rounded : Icons.error_rounded),
                color: success ? pal.success : pal.danger,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 12.5, color: pal.textPrimary, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

/// دیالوگ تأیید با استایل اختصاصی (RTL).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأیید',
  String cancelLabel = 'انصراف',
  bool destructive = false,
  IconData icon = Icons.help_outline_rounded,
}) async {
  final pal = context.pal;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (destructive ? pal.danger : pal.primary).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: destructive ? pal.danger : pal.primaryBright, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pal.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: TextStyle(fontSize: 12.5, color: pal.textSecondary, height: 1.8),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: destructive ? pal.danger : pal.primary,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// نمایش شیت پایین با کشیدن‌کننده و عنوان.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
  bool scrollable = true,
}) {
  final pal = context.pal;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: pal.backgroundAlt,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.brTopXxl),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(color: pal.borderStrong, borderRadius: AppRadius.brPill),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: pal.textPrimary),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, size: 18, color: pal.textMuted),
                  ),
                ],
              ),
            ),
            Flexible(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: child,
                    )
                  : Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: child),
            ),
          ],
        ),
      ),
    ),
  );
}
