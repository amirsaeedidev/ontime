import 'package:flutter/widgets.dart';

import '../../app/theme/app_theme.dart';

/// ویجت جایگزین خطا که **هیچ وابستگی‌ای به محیط (Ancestor)** ندارد.
///
/// چرا این‌قدر «بی‌آلایش» نوشته شده است؟
/// `ErrorWidget.builder` در همان مکانی ساخته می‌شود که خطا رخ داده است؛ اگر آن
/// مکان بیرون از `MaterialApp`/`Directionality` باشد (مثلاً خطای رخ‌داده در
/// لایهٔ تزریق وابستگی یا در `MaterialApp.builder`)، استفاده از `Text` باعث
/// خطای «No Directionality widget found» می‌شود و همان خطا دوباره
/// `ErrorWidget.builder` را صدا می‌زند → بازگشت بی‌پایان و Stack Overflow.
///
/// بنابراین اینجا:
///  • از `RichText` با `textDirection` صریح استفاده می‌شود (نیازی به
///    Directionality سراسری ندارد).
///  • هیچ استفاده‌ای از `Theme.of`، `MediaQuery.of`، `Material` و مانند آن نیست.
///  • یک نگهبان بازگشتی (guard) دارد تا حتی در بدترین حالت، چرخه در همان
///    مرحلهٔ اول متوقف شود و برنامه هرگز با Stack Overflow از کار نیفتد.
class BootErrorWidget extends StatelessWidget {
  const BootErrorWidget({
    super.key,
    this.title = 'خطا در نمایش این بخش',
    this.details,
    this.accent = const Color(0xFFEF4444),
    this.compact = true,
  });

  final String title;
  final String? details;
  final Color accent;
  final bool compact;

  /// اگر هنگام ساخت خودِ این ویجت خطایی رخ دهد، این پرچم از حلقه جلوگیری می‌کند.
  static bool _building = false;

  @override
  Widget build(BuildContext context) {
    if (_building) {
      // چرخهٔ خطا: به‌جای تکرار بی‌پایان، یک ویجت خالی برمی‌گردانیم.
      return const SizedBox.shrink();
    }
    _building = true;
    try {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: _content(),
      );
    } finally {
      _building = false;
    }
  }

  Widget _content() {
    const background = Color(0xFF111A2B);
    final text = details == null || details!.isEmpty
        ? title
        : '$title\n${details!.length > 180 ? '${details!.substring(0, 180)}…' : details}';

    return ColoredBox(
      color: background,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 24),
          child: RichText(
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: compact ? 11 : 14,
                height: 1.7,
                color: compact ? accent : const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
