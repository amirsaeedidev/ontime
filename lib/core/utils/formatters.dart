import 'fa_num.dart';
import 'jalali.dart';

/// قالب‌بندی‌های مشترک نمایش (ارقام فارسی، مبلغ، ساعت، شماره تماس).
class Fmt {
  const Fmt._();

  /// محصور کردن رشته‌های عددی در نشانگر LTR تا ترتیب ارقام در متن راست‌به‌چپ حفظ شود.
  static String ltr(String value) => '\u202A$value\u202C';

  /// ۱٬۲۵۰٬۰۰۰ با جداکننده هزارگان فارسی.
  static String money(num value, {String unit = 'تومان', bool withUnit = true}) {
    final raw = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buffer.write('٬');
      buffer.write(raw[i]);
    }
    final text = FaNum.convert(buffer.toString());
    return withUnit ? '${ltr(text)} $unit' : ltr(text);
  }

  /// خلاصه مبلغ برای کارت‌ها: ۱۲٬۵۰۰٬۰۰۰ → ۱۲٫۵ میلیون
  static String compactMoney(num value) {
    if (value >= 1000000000) {
      final v = value / 1000000000;
      return '${ltr(_trim(v))} میلیارد تومان';
    }
    if (value >= 1000000) {
      final v = value / 1000000;
      return '${ltr(_trim(v))} میلیون تومان';
    }
    if (value >= 1000) {
      final v = value / 1000;
      return '${ltr(_trim(v))} هزار تومان';
    }
    return '${ltr(FaNum.ofInt(value.round()))} تومان';
  }

  /// نسخه کوتاه برای کارت‌های آماری: ۱۴٫۳ میلیون
  static String compactMoneyShort(num value) {
    if (value >= 1000000000) return '${ltr(_trim(value / 1000000000))} میلیارد';
    if (value >= 1000000) return '${ltr(_trim(value / 1000000))} میلیون';
    if (value >= 1000) return '${ltr(_trim(value / 1000))} هزار';
    return ltr(FaNum.ofInt(value.round()));
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
    return FaNum.convert(s.replaceAll('.', '٫'));
  }

  /// ۰۹:۳۰
  static String time(int hour, int minute) => ltr(
        FaNum.convert('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}'),
      );

  static String clock(DateTime dt) => time(dt.hour, dt.minute);

  /// ۰۹:۳۰ تا ۱۰:۱۰
  static String range(int h1, int m1, int h2, int m2) => '${time(h1, m1)} تا ${time(h2, m2)}';

  /// ۰۹۱۲۳۴۵۶۷۸۹ → ۰۹۱۲ ۳۴۵ ۶۷۸۹
  static String phone(String value) {
    final digits = FaNum.toLatin(value).replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      final parts = [digits.substring(0, 4), digits.substring(4, 7), digits.substring(7)];
      return ltr(FaNum.convert(parts.join(' ')));
    }
    return ltr(FaNum.convert(digits.isEmpty ? value : digits));
  }

  /// ۴۵ دقیقه / ۱ ساعت و ۳۰ دقیقه
  static String duration(int minutes) {
    if (minutes < 60) return '${FaNum.ofInt(minutes)} دقیقه';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '${FaNum.ofInt(h)} ساعت';
    return '${FaNum.ofInt(h)} ساعت و ${FaNum.ofInt(m)} دقیقه';
  }

  /// «۲ روز پیش» / «۳ ساعت پیش»
  static String timeAgo(DateTime dateTime, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(dateTime);
    if (diff.inMinutes < 1) return 'همین حالا';
    if (diff.inMinutes < 60) return '${FaNum.ofInt(diff.inMinutes)} دقیقه پیش';
    if (diff.inHours < 24) return '${FaNum.ofInt(diff.inHours)} ساعت پیش';
    if (diff.inDays < 30) return '${FaNum.ofInt(diff.inDays)} روز پیش';
    if (diff.inDays < 365) return '${FaNum.ofInt(diff.inDays ~/ 30)} ماه پیش';
    return '${FaNum.ofInt(diff.inDays ~/ 365)} سال پیش';
  }

  /// تاریخ و ساعت کامل شمسی: ۱۵ دی ۱۴۰۴ - ۰۹:۳۰
  static String jalaliDateTime(DateTime dateTime) {
    final j = JalaliDate.fromDateTime(dateTime);
    return '${j.long} - ${clock(dateTime)}';
  }

  static String jalaliDate(DateTime dateTime) => JalaliDate.fromDateTime(dateTime).long;

  static String percent(num value) => '${ltr(FaNum.convert(_trim(value.toDouble())))}٪';

  /// ۶۴٪ برای نمودارها (بدون اعشار اضافه)
  static String percentPlain(num value) => '${ltr(FaNum.ofInt(value.round()))}٪';
}
