import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ontime/core/widgets/boot_error_widget.dart';

/// متن رندرشده در ویجت خطا (ویجت خطا از RichText استفاده می‌کند و نه Text،
/// چون Text به Directionality نیاز دارد).
String renderedText(WidgetTester tester) =>
    tester.widget<RichText>(find.byType(RichText)).text.toPlainText();

class _Throwing extends StatelessWidget {
  const _Throwing(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => throw StateError(message);
}

/// رگرسیون برای خطای واقعی گزارش‌شده:
/// `_StartupErrorBox ← _StartupErrorBox ← …` + `Stack Overflow` +
/// «No Directionality widget found».
///
/// علت: ویجت جایگزین خطا از `Text` استفاده می‌کرد؛ وقتی بیرون از `MaterialApp`
/// ساخته می‌شد، خودش خطا می‌داد و همان خطا دوباره builder را صدا می‌زد و حلقه
/// تا Stack Overflow ادامه می‌یابد. این تست تضمین می‌کند ویجت خطا **بدون هیچ
/// Ancestor** ساخته شود و حلقه ایجاد نشود.
void main() {
  testWidgets('ویجت خطا بدون Directionality/MaterialApp رندر می‌شود', (tester) async {
    await tester.pumpWidget(
      const BootErrorWidget(title: 'خطا در نمایش این بخش', details: 'boom'),
    );

    expect(tester.takeException(), isNull);
    expect(renderedText(tester), contains('خطا در نمایش این بخش'));

    final richText = tester.widget<RichText>(find.byType(RichText));
    expect(richText.textDirection, TextDirection.rtl);
    expect((richText.text as TextSpan).style?.fontFamily, 'Lalezar');
  });

  testWidgets('خطای ساخت ویجت در درختِ بدون Ancestor به ویجت خطا تبدیل می‌شود', (tester) async {
    final previous = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) => BootErrorWidget(
          title: 'خطا',
          details: details.exceptionAsString(),
          compact: true,
        );
    try {
      await tester.pumpWidget(const _Throwing('boom'));

      final error = tester.takeException();
      // خطای اصلی باید همان «boom» باشد، نه خطای جهت متن.
      expect('$error', contains('boom'));
      expect('$error', isNot(contains('Directionality')));
      // و ویجت خطا باید در درخت نصب شده باشد.
      expect(find.byType(BootErrorWidget), findsOneWidget);
      expect(renderedText(tester), contains('boom'));
    } finally {
      ErrorWidget.builder = previous;
    }
  });

  testWidgets('ویجت خطا داخل ErrorWidget واقعیِ فریم‌ورک بدون Directionality', (tester) async {
    // محیط کاملاً خالی: نه MaterialApp، نه Directionality.
    // اگر ویجت خطا به Directionality نیاز داشت، همین‌جا حلقه و Stack Overflow می‌شد.
    final previous = ErrorWidget.builder;
    ErrorWidget.builder = (FlutterErrorDetails details) => BootErrorWidget(
          title: 'خطا',
          details: details.exceptionAsString(),
          compact: true,
        );
    try {
      await tester.pumpWidget(const _Throwing('بدون جهت'));

      final error = tester.takeException();
      expect('$error', contains('بدون جهت'));
      expect('$error', isNot(contains('No Directionality widget found')));
      expect(find.byType(BootErrorWidget), findsOneWidget);
      // هیچ خطای دیگری (یعنی حلقهٔ خطا) نباید رخ داده باشد.
      expect(tester.takeException(), isNull);

      // چند فریم بعد هم نباید چیزی جدید خطا بدهد.
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
    } finally {
      ErrorWidget.builder = previous;
    }
  });

  testWidgets('ساخت مکرر ویجت خطا هرگز Stack Overflow نمی‌دهد', (tester) async {
    for (var i = 0; i < 40; i++) {
      await tester.pumpWidget(BootErrorWidget(title: 'تکرار $i', compact: i.isEven));
    }
    expect(tester.takeException(), isNull);
    expect(find.byType(BootErrorWidget), findsOneWidget);
  });

  testWidgets('ویجت خطا به Theme/Material نیاز ندارد', (tester) async {
    await tester.pumpWidget(
      BootErrorWidget(
        title: 'اجرای برنامه با خطا مواجه شد',
        details: List<String>.filled(400, 'x').join(),
        compact: false,
      ),
    );
    expect(tester.takeException(), isNull);
    final richText = tester.widget<RichText>(find.byType(RichText));
    // متن طولانی کوتاه می‌شود تا کل صفحه را نگیرد.
    expect((richText.text as TextSpan).text!.length, lessThan(260));
  });
}
