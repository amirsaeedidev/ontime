import 'package:flutter_test/flutter_test.dart';
import 'package:ontime/core/utils/jalali.dart';

void main() {
  test('تبدیل میلادی به شمسی و بازگشت', () {
    final j = JalaliDate.fromDateTime(DateTime(2026, 11, 12));
    expect(j.year, 1405);
    expect(j.month, 8);
    expect(j.day, 21);
    expect(j.toDateTime().year, 2026);
    expect(j.toDateTime().month, 11);
    expect(j.toDateTime().day, 12);
  });

  test('نوروز ۱۴۰۵ برابر ۲۱ مارس ۲۰۲۶ است', () {
    final j = JalaliDate.fromDateTime(DateTime(2026, 3, 21));
    expect(j.year, 1405);
    expect(j.month, 1);
    expect(j.day, 1);
  });

  test('طول ماه‌ها و سال کبیسه', () {
    expect(JalaliDate(1405, 1, 1).monthLength, 31);
    expect(JalaliDate(1405, 7, 1).monthLength, 30);
    expect(JalaliDate(1403, 12, 1).monthLength, 30); // سال کبیسه
    expect(JalaliDate(1404, 12, 1).monthLength, 29);
  });

  test('افزودن و کاهش روز', () {
    final d = JalaliDate(1405, 8, 21);
    expect(d.addDays(9).day, 30);
    expect(d.addDays(10).month, 9);
    expect(d.addDays(10).day, 1);
    expect(d.addDays(-21).month, 7);
    expect(d.addMonths(1).month, 9);
    expect(d.addMonths(-8).year, 1404);
  });

  test('نام روز هفته', () {
    expect(JalaliDate(1405, 8, 21).weekdayName, isNotEmpty);
  });
}
