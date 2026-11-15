import 'appointment.dart';

/// آمار تجمیعی پیشخوان.
class DashboardStats {
  const DashboardStats({
    required this.totalAppointments,
    required this.todayAppointments,
    required this.upcomingAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.totalRevenue,
    required this.monthRevenue,
    required this.totalCustomers,
    required this.activeEmployees,
    required this.weeklyTrend,
    required this.weekdayPerformance,
    required this.statusBreakdown,
  });

  final int totalAppointments;
  final int todayAppointments;
  final int upcomingAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final num totalRevenue;
  final num monthRevenue;
  final int totalCustomers;
  final int activeEmployees;

  /// روند هفتگی (درصد اشغال هر روز هفته).
  final List<WeekdayPerformance> weeklyTrend;

  /// عملکرد روزهای هفته برای نمودار پیشخوان.
  final List<WeekdayPerformance> weekdayPerformance;

  final Map<String, int> statusBreakdown;

  int get pendingAppointments => statusBreakdown['در انتظار'] ?? 0;

  double get completionRate =>
      totalAppointments == 0 ? 0 : completedAppointments / totalAppointments * 100;

  double get averageRevenuePerAppointment =>
      completedAppointments == 0 ? 0 : totalRevenue / completedAppointments;
}

/// عملکرد یک روز از هفته برای نمودار.
class WeekdayPerformance {
  const WeekdayPerformance({
    required this.label,
    required this.percent,
    required this.count,
    required this.revenue,
    this.isPeak = false,
  });

  final String label;
  final int percent;
  final int count;
  final num revenue;
  final bool isPeak;
}

/// نقطه درآمد برای نمودارهای گزارش.
class RevenuePoint {
  const RevenuePoint({required this.label, required this.value, this.secondary = 0});

  final String label;
  final num value;
  final num secondary;
}

/// ردیف فعالیت اخیر مشتری روی پیشخوان.
class RecentActivityItem {
  const RecentActivityItem({
    required this.appointment,
    required this.timeLabel,
  });

  final Appointment appointment;
  final String timeLabel;
}
