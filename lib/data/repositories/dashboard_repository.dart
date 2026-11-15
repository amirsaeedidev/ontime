import '../../core/utils/jalali.dart';
import '../mock/app_database.dart';
import '../models/appointment.dart';
import '../models/dashboard_stats.dart';
import '../models/enums.dart';

/// بازه زمانی گزارش پیشخوان.
enum StatsPeriod {
  weekly('هفتگی'),
  monthly('ماهانه');

  const StatsPeriod(this.label);
  final String label;
}

abstract class DashboardRepository {
  Future<DashboardStats> fetchStats({StatsPeriod period = StatsPeriod.weekly});

  Future<List<Appointment>> fetchUpcoming({int limit = 4});

  Future<List<RevenuePoint>> fetchRevenueSeries({int months = 6});

  Future<List<RevenuePoint>> fetchServiceRevenue({int limit = 5});
}

class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository(this._db);

  final AppDatabase _db;

  @override
  Future<DashboardStats> fetchStats({StatsPeriod period = StatsPeriod.weekly}) async {
    await _db.delay(180);
    final all = _db.appointments;
    final today = JalaliDate.today();
    final now = DateTime.now();

    final periodStart = period == StatsPeriod.weekly
        ? today.addDays(-today.weekday)
        : JalaliDate(today.year, today.month, 1);
    final periodItems = all.where((a) => !a.jalali.isBefore(periodStart)).toList();

    final completed = periodItems.where((a) => a.status == AppointmentStatus.completed);
    final cancelled = periodItems.where((a) => a.status == AppointmentStatus.cancelled || a.status == AppointmentStatus.noShow);

    final totalRevenue = all
        .where((a) => a.status == AppointmentStatus.completed)
        .fold<num>(0, (sum, a) => sum + a.price);

    final monthStart = JalaliDate(today.year, today.month, 1);
    final monthRevenue = all
        .where((a) => a.status == AppointmentStatus.completed && !a.jalali.isBefore(monthStart))
        .fold<num>(0, (sum, a) => sum + a.price);

    final activeEmployees = _db.employees.where((e) => e.isActive).length;
    final slotsPerDay = activeEmployees == 0 ? 1 : activeEmployees * 4;

    // نمودار عملکرد هفته جاری (شنبه تا جمعه).
    final weekStart = today.addDays(-today.weekday);
    final performance = <WeekdayPerformance>[];
    for (var i = 0; i < 7; i++) {
      final date = weekStart.addDays(i);
      final dayItems = all.where((a) => a.jalali.sameDay(date) && a.status != AppointmentStatus.cancelled).toList();
      final percent = ((dayItems.length / slotsPerDay) * 100).clamp(8, 100).round();
      performance.add(
        WeekdayPerformance(
          label: JalaliDate.weekdayNames[i],
          percent: percent,
          count: dayItems.length,
          revenue: dayItems.fold<num>(0, (sum, a) => sum + a.price),
        ),
      );
    }
    final maxIndex = performance.isEmpty
        ? 0
        : performance.indexWhere((p) => p.percent == performance.map((e) => e.percent).reduce((a, b) => a > b ? a : b));
    if (performance.isNotEmpty) {
      performance[maxIndex] = WeekdayPerformance(
        label: performance[maxIndex].label,
        percent: performance[maxIndex].percent,
        count: performance[maxIndex].count,
        revenue: performance[maxIndex].revenue,
        isPeak: true,
      );
    }

    final statusBreakdown = <String, int>{
      for (final status in AppointmentStatus.values) status.label: periodItems.where((a) => a.status == status).length,
    };

    return DashboardStats(
      totalAppointments: periodItems.length,
      todayAppointments: all.where((a) => a.isToday && a.status != AppointmentStatus.cancelled).length,
      upcomingAppointments: all.where((a) => a.status.isActive && a.startAt.isAfter(now)).length,
      completedAppointments: completed.length,
      cancelledAppointments: cancelled.length,
      totalRevenue: totalRevenue,
      monthRevenue: monthRevenue,
      totalCustomers: _db.customers.length,
      activeEmployees: activeEmployees,
      weeklyTrend: performance,
      weekdayPerformance: performance,
      statusBreakdown: statusBreakdown,
    );
  }

  @override
  Future<List<Appointment>> fetchUpcoming({int limit = 4}) async {
    await _db.delay(120);
    final now = DateTime.now();
    final list = _db.appointments
        .where((a) => a.status.isActive && a.startAt.isAfter(now.subtract(const Duration(hours: 1))))
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    return list.take(limit).toList();
  }

  @override
  Future<List<RevenuePoint>> fetchRevenueSeries({int months = 6}) async {
    await _db.delay(140);
    final today = JalaliDate.today();
    final result = <RevenuePoint>[];
    for (var i = months - 1; i >= 0; i--) {
      final monthDate = JalaliDate(today.year, today.month, 1).addMonths(-i);
      final nextMonth = monthDate.addMonths(1);
      final items = _db.appointments.where((a) {
        final j = a.jalali;
        return !j.isBefore(monthDate) && j.isBefore(nextMonth);
      }).toList();
      final revenue = items
          .where((a) => a.status == AppointmentStatus.completed)
          .fold<num>(0, (sum, a) => sum + a.price);
      result.add(
        RevenuePoint(
          label: monthDate.monthName,
          value: revenue,
          secondary: items.length,
        ),
      );
    }

    // ماه‌های گذشته در داده نمونه نوبتی ندارند؛ برای نمایش واقع‌گرایانه نمودار،
    // تاریخچه با ضریب ثابت نسبت به درآمد ماه جاری بازسازی می‌شود.
    final currentRevenue = result.isEmpty ? 0 : result.last.value;
    if (currentRevenue > 0) {
      const factors = [0.58, 0.72, 0.65, 0.84, 0.76, 0.91, 0.69, 0.88, 0.63, 0.94, 0.8];
      for (var i = 0; i < result.length - 1; i++) {
        if (result[i].value < currentRevenue * 0.4) {
          final point = result[i];
          result[i] = RevenuePoint(
            label: point.label,
            value: (currentRevenue * factors[i % factors.length]).round(),
            secondary: point.secondary == 0 ? (18 + i * 3) : point.secondary,
          );
        }
      }
    }
    return result;
  }

  @override
  Future<List<RevenuePoint>> fetchServiceRevenue({int limit = 5}) async {
    await _db.delay(120);
    final totals = <String, num>{};
    for (final a in _db.appointments.where((a) => a.status == AppointmentStatus.completed)) {
      totals[a.serviceName] = (totals[a.serviceName] ?? 0) + a.price;
    }
    final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return [for (final e in entries.take(limit)) RevenuePoint(label: e.key, value: e.value)];
  }
}
