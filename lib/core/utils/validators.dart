import 'fa_num.dart';

/// اعتبارسنجی فرم‌های فارسی.
class Validators {
  const Validators._();

  static String? required(String? value, {String label = 'این فیلد'}) {
    if (value == null || value.trim().isEmpty) return '$label الزامی است';
    return null;
  }

  static String? mobile(String? value) {
    final digits = FaNum.toLatin(value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'شماره موبایل الزامی است';
    if (digits.length != 11) return 'شماره موبایل باید ۱۱ رقم باشد';
    if (!digits.startsWith('09')) return 'شماره موبایل باید با ۰۹ شروع شود';
    return null;
  }

  static String? price(String? value) {
    final digits = FaNum.toLatin(value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'مبلغ الزامی است';
    if (int.tryParse(digits) == 0) return 'مبلغ باید بزرگ‌تر از صفر باشد';
    return null;
  }

  static String? positiveInt(String? value, {String label = 'مقدار', int min = 1, int max = 999}) {
    final digits = FaNum.toLatin(value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '$label الزامی است';
    final n = int.tryParse(digits);
    if (n == null) return 'عدد معتبر وارد کنید';
    if (n < min) return '$label نباید کمتر از $min باشد';
    if (n > max) return '$label نباید بیشتر از $max باشد';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'نام کاربری الزامی است';
    if (value.trim().length < 3) return 'نام کاربری باید حداقل ۳ نویسه باشد';
    return null;
  }
}
