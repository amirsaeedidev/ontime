import 'package:flutter_test/flutter_test.dart';
import 'package:ontime/core/utils/fa_num.dart';
import 'package:ontime/core/utils/formatters.dart';

String strip(String s) => s.replaceAll('\u202A', '').replaceAll('\u202C', '');

void main() {
  test('تبدیل ارقام فارسی و بازگشت', () {
    expect(FaNum.convert('09123456789'), '۰۹۱۲۳۴۵۶۷۸۹');
    expect(FaNum.toLatin('۰۹۱۲۳۴۵۶۷۸۹'), '09123456789');
    expect(FaNum.ofInt(1405), '۱۴۰۵');
  });

  test('قالب مبلغ با جداکننده هزارگان', () {
    expect(strip(Fmt.money(1250000)), '۱٬۲۵۰٬۰۰۰ تومان');
    expect(strip(Fmt.money(550000, withUnit: false)), '۵۵۰٬۰۰۰');
  });

  test('قالب مبلغ کوتاه', () {
    expect(strip(Fmt.compactMoneyShort(14300000)), '۱۴٫۳ میلیون');
  });

  test('قالب زمان همیشه چپ‌به‌راست است', () {
    final t = Fmt.time(8, 5);
    expect(t.startsWith('\u202A'), isTrue);
    expect(strip(t), '۰۸:۰۵');
  });

  test('قالب شماره موبایل', () {
    expect(strip(Fmt.phone('09123456789')), '۰۹۱۲ ۳۴۵ ۶۷۸۹');
  });
}
