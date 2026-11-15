import 'fa_num.dart';

/// تاریخ شمسی (جلالی) با پشتیبانی کامل از تبدیل و قالب‌بندی فارسی.
class JalaliDate implements Comparable<JalaliDate> {
  const JalaliDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  static const List<String> monthNames = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  static const List<String> weekdayNames = [
    'شنبه', 'یک‌شنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه',
  ];

  static const List<String> weekdayShortNames = [
    'ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج',
  ];

  /// نام ماه به فارسی.
  String get monthName => monthNames[month - 1];

  /// روز هفته؛ ۰ = شنبه ... ۶ = جمعه.
  int get weekday => ((toJdn() + 2) % 7).toInt();

  String get weekdayName => weekdayNames[weekday];

  /// تبدیل به شماره روز جولیَن.
  int toJdn() => toJdnRaw();

  DateTime toDateTime() => DateTime(_gYear, _gMonth, _gDay);

  static JalaliDate fromDateTime(DateTime date) => _fromJdn(_g2d(date.year, date.month, date.day));

  static JalaliDate fromJdn(int jdn) => _fromJdn(jdn);

  static JalaliDate today() => fromDateTime(DateTime.now());

  bool get isLeapYear => _isLeap(year);

  int get monthLength => month <= 6 ? 31 : (month <= 11 ? 30 : (isLeapYear ? 30 : 29));

  JalaliDate addDays(int days) => _fromJdn(toJdn() + days);

  JalaliDate addMonths(int months) {
    var y = year;
    var m = month + months;
    while (m > 12) {
      m -= 12;
      y += 1;
    }
    while (m < 1) {
      m += 12;
      y -= 1;
    }
    final d = day > _monthLength(y, m) ? _monthLength(y, m) : day;
    return JalaliDate(y, m, d);
  }

  bool sameDay(JalaliDate other) => year == other.year && month == other.month && day == other.day;

  bool isBefore(JalaliDate other) => compareTo(other) < 0;
  bool isAfter(JalaliDate other) => compareTo(other) > 0;

  /// فاصله روزها نسبت به این تاریخ.
  int daysUntil(JalaliDate other) => other.toJdn() - toJdn();

  /// ۱۴۰۴/۱۰/۱۵
  String get numeric => FaNum.convert('$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}');

  /// ۱۵ دی ۱۴۰۴
  String get long => '${FaNum.convert('$day')} $monthName ${FaNum.convert('$year')}';

  /// ۱۵ دی
  String get short => '${FaNum.convert('$day')} $monthName';

  /// ۱۰:۳۰ → برای ساعت از ابزار دیگری استفاده می‌شود.
  String get iso => '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  static JalaliDate parseIso(String value) {
    final parts = value.split('-');
    return JalaliDate(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  /// برچسب نسبی دوستانه: امروز / فردا / دیروز / روز هفته.
  String relativeLabel({JalaliDate? reference}) {
    final ref = reference ?? today();
    final diff = ref.daysUntil(this);
    if (diff == 0) return 'امروز';
    if (diff == 1) return 'فردا';
    if (diff == -1) return 'دیروز';
    if (diff > 1 && diff < 7) return weekdayName;
    if (diff < -1 && diff > -7) return weekdayName;
    return long;
  }

  @override
  int compareTo(JalaliDate other) => toJdn().compareTo(other.toJdn());

  @override
  bool operator ==(Object other) =>
      other is JalaliDate && other.year == year && other.month == other.month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso;

  // ---------------------------------------------------------------------------
  // محاسبات داخلی تقویم
  // ---------------------------------------------------------------------------

  static int _div(int a, int b) => (a / b).truncate();

  static int _mod(int a, int b) => a - _div(a, b) * b;

  static int _g2d(int gy, int gm, int gd) {
    var d = _div((gy + _div(gm - 8, 6) + 100100) * 1461, 4) +
        _div(153 * ((gm + 9) % 12) + 2, 5) +
        gd -
        34840408;
    d = d - _div(_div(gy + 100100 + _div(gm - 8, 6), 100) * 3, 4) + 752;
    return d;
  }

  static List<int> _d2g(int jdn) {
    var j = 4 * jdn + 139361631;
    j = j + _div(_div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908;
    final i = _div(_mod(j, 1461), 4) * 5 + 308;
    final gd = _div(_mod(i, 153), 5) + 1;
    final gm = _mod(_div(i, 153), 12) + 1;
    final gy = _div(j, 1461) - 100100 + _div(8 - gm, 6);
    return [gy, gm, gd];
  }

  static JalaliDate _fromJdn(int jdn) {
    final gy = _d2g(jdn)[0];
    var jy = gy - 621;
    final r = _jalCal(jy);
    final jdn1f = _g2d(gy, 3, r[1]);
    var k = jdn - jdn1f;
    if (k >= 0) {
      if (k <= 185) {
        return JalaliDate(jy, 1 + _div(k, 31), _mod(k, 31) + 1);
      }
      k -= 186;
    } else {
      jy -= 1;
      k += 179;
      if (r[0] == 1) k += 1;
    }
    return JalaliDate(jy, 7 + _div(k, 30), _mod(k, 30) + 1);
  }

  /// خروجی: [leap, march]
  static List<int> _jalCal(int jy) {
    const breaks = [
      -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210,
      1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
    ];
    final gy = jy + 621;
    var leapJ = -14;
    var jp = breaks[0];
    var jump = 0;
    for (var i = 1; i < breaks.length; i++) {
      final jm = breaks[i];
      jump = jm - jp;
      if (jy < jm) break;
      leapJ = leapJ + _div(jump, 33) * 8 + _div(_mod(jump, 33), 4);
      jp = jm;
    }
    var n = jy - jp;
    leapJ = leapJ + _div(n, 33) * 8 + _div(_mod(n, 33) + 3, 4);
    if (_mod(jump, 33) == 4 && jump - n == 4) leapJ += 1;
    final leapG = _div(gy, 4) - _div((_div(gy, 100) + 1) * 3, 4) - 150;
    final march = 20 + leapJ - leapG;
    if (jump - n < 6) {
      n = n - jump + _div(jump + 4, 33) * 33;
    }
    var leap = _mod(_mod(n + 1, 33) - 1, 4);
    if (leap == -1) leap = 4;
    return [leap, march];
  }

  static bool _isLeap(int jy) => _jalCal(jy)[0] == 0;

  static int _monthLength(int jy, int jm) =>
      jm <= 6 ? 31 : (jm <= 11 ? 30 : (_isLeap(jy) ? 30 : 29));

  int get _gYear => _d2g(toJdnRaw())[0];
  int get _gMonth => _d2g(toJdnRaw())[1];
  int get _gDay => _d2g(toJdnRaw())[2];


  /// JDN بر اساس تاریخ شمسی.
  int toJdnRaw() {
    final r = _jalCal(year);
    return _g2d(year + 621, 3, r[1]) + (month - 1) * 31 - _div(month, 7) * (month - 7) + day - 1;
  }
}
