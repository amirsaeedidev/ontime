/// ابزار تبدیل و نمایش ارقام فارسی.
class FaNum {
  static const List<String> _fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  /// تبدیل ارقام لاتین به فارسی.
  static String convert(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 48 && rune <= 57) {
        buffer.write(_fa[rune - 48]);
      } else {
        buffer.write(String.fromCharCode(rune));
      }
    }
    return buffer.toString();
  }

  /// تبدیل ارقام فارسی/عربی به لاتین (برای ورودی‌ها).
  static String toLatin(String input) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      final faIndex = fa.indexOf(ch);
      final arIndex = ar.indexOf(ch);
      if (faIndex >= 0) {
        buffer.write(faIndex);
      } else if (arIndex >= 0) {
        buffer.write(arIndex);
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  static String ofInt(int value) => convert(value.toString());
  static String ofNum(num value) => convert(value.toString());
}

extension FaNumX on String {
  String get fa => FaNum.convert(this);
}

extension FaNumIntX on int {
  String get faNum => FaNum.convert(toString());
}
