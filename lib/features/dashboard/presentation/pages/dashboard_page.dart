import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/appointment.dart';
import '../../../../data/models/dashboard_stats.dart';
import '../../../../data/repositories/dashboard_repository.dart';
import '../../../activity_logs/presentation/providers/activity_provider.dart';
import '../../../appointments/presentation/widgets/appointment_tile.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_sections.dart';
import '../widgets/performance_chart.dart';

/// پیشخوان مدیریت — بازسازی صفحه مرجع ONTIME.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final activity = context.watch<ActivityProvider>();
    final pal = context.pal;
    final stats = provider.stats;

    return PageScaffold(
      title: 'پیشخوان',
      subtitle: 'نمای کلی عملکرد مجموعه',
      icon: Icons.dashboard_rounded,
      showLogo: true,
      onClose: () => context.go('/dashboard'),
      onBell: () => context.push('/activity'),
      onProfile: () => context.push('/settings'),
      actions: [
        SoftButton(label: 'گزارش‌ها', icon: Icons.insights_rounded, onTap: () => context.push('/reports')),
        SoftButton(label: 'صفحه رزرو', icon: Icons.public_rounded, onTap: () => context.push('/book')),
      ],
      scrollable: true,
      child: provider.loading && stats == null
          ? const LoadingState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    if (!wide) {
                      return _MobileDashboard(
                        stats: stats!,
                        upcoming: provider.upcoming,
                        period: provider.period,
                        onPeriodChanged: provider.setPeriod,
                        revenueSeries: provider.revenueSeries,
                        logs: activity.recent,
                      );
                    }
                    return _DesktopDashboard(
                      stats: stats!,
                      upcoming: provider.upcoming,
                      period: provider.period,
                      onPeriodChanged: provider.setPeriod,
                      revenueSeries: provider.revenueSeries,
                      logs: activity.recent,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'صفحه رزرو عمومی: ontime.app/book/ontime-salon',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 10, color: pal.textMuted),
                  ),
                ),
              ],
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// چیدمان موبایل (مطابق تصویر مرجع)
// -----------------------------------------------------------------------------
class _MobileDashboard extends StatelessWidget {
  const _MobileDashboard({
    required this.stats,
    required this.upcoming,
    required this.period,
    required this.onPeriodChanged,
    required this.revenueSeries,
    required this.logs,
  });

  final DashboardStats stats;
  final List<Appointment> upcoming;
  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onPeriodChanged;
  final List<RevenuePoint> revenueSeries;
  final List logs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroStatsCard(stats: stats, period: period, onPeriodChanged: onPeriodChanged),
        const SizedBox(height: 14),
        GradientCta(
          title: 'ثبت نوبت جدید',
          subtitle: 'رزرو سریع در چند ثانیه',
          onPressed: () => context.push('/appointments/new'),
        ),
        const SizedBox(height: 18),
        SectionHeader(
          title: 'نوبت‌ها و رزروهای جدید',
          actionLabel: 'مشاهده همه',
          onAction: () => context.go('/appointments'),
        ),
        const SizedBox(height: 10),
        if (upcoming.isEmpty)
          const EmptyState(
            title: 'نوبت پیش‌رویی وجود ندارد',
            description: 'برای ثبت نوبت جدید از دکمه بالا استفاده کنید.',
            compact: true,
          )
        else
          for (final appointment in upcoming) ...[
            AppointmentTile(
              appointment: appointment,
              onTap: () => context.push('/appointments/${appointment.id}'),
            ),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 8),
        SectionHeader(title: 'دسترسی سریع'),
        const SizedBox(height: 10),
        const QuickActionsRow(),
        const SizedBox(height: 18),
        KpiGrid(stats: stats),
        const SizedBox(height: 12),
        StatusBreakdownCard(counts: stats.statusBreakdown),
        const SizedBox(height: 12),
        RevenueCard(data: revenueSeries),
        const SizedBox(height: 12),
        RecentActivityCard(logs: logs.cast()),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// چیدمان دسکتاپ/تبلت.
// -----------------------------------------------------------------------------
class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({
    required this.stats,
    required this.upcoming,
    required this.period,
    required this.onPeriodChanged,
    required this.revenueSeries,
    required this.logs,
  });

  final DashboardStats stats;
  final List<Appointment> upcoming;
  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onPeriodChanged;
  final List<RevenuePoint> revenueSeries;
  final List logs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _HeroStatsCard(stats: stats, period: period, onPeriodChanged: onPeriodChanged),
                  const SizedBox(height: 12),
                  GradientCta(
                    title: 'ثبت نوبت جدید',
                    subtitle: 'رزرو سریع در چند ثانیه',
                    height: 68,
                    compact: true,
                    onPressed: () => context.push('/appointments/new'),
                  ),
                  const SizedBox(height: 12),
                  const QuickActionsRow(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  KpiGrid(stats: stats, compact: true),
                  const SizedBox(height: 12),
                  StatusBreakdownCard(counts: stats.statusBreakdown),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeader(
                      title: 'نوبت‌ها و رزروهای جدید',
                      actionLabel: 'مشاهده همه',
                      onAction: () => context.go('/appointments'),
                    ),
                    const SizedBox(height: 12),
                    if (upcoming.isEmpty)
                      const EmptyState(compact: true, title: 'نوبت پیش‌رویی وجود ندارد')
                    else
                      for (final appointment in upcoming) ...[
                        AppointmentTile(
                          appointment: appointment,
                          onTap: () => context.push('/appointments/${appointment.id}'),
                        ),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  RevenueCard(data: revenueSeries),
                  const SizedBox(height: 12),
                  RecentActivityCard(logs: logs.cast(), maxItems: 5),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// کارت اصلی آمار + نمودار (بازسازی دقیق تصویر مرجع)
// -----------------------------------------------------------------------------
class _HeroStatsCard extends StatelessWidget {
  const _HeroStatsCard({
    required this.stats,
    required this.period,
    required this.onPeriodChanged,
  });

  final DashboardStats stats;
  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final completionRate = stats.totalAppointments == 0
        ? 0
        : (stats.completedAppointments / stats.totalAppointments * 100).round();

    return AppCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آمار نوبت‌ها و عملکرد',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: pal.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${FaNum.ofInt(stats.totalAppointments)} نوبت',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: pal.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TrendChip(value: '${FaNum.ofInt(completionRate)}٪', positive: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PillToggle(
                options: const ['هفتگی', 'ماهانه'],
                selectedIndex: period == StatsPeriod.weekly ? 0 : 1,
                onChanged: (i) => onPeriodChanged(i == 0 ? StatsPeriod.weekly : StatsPeriod.monthly),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'تکمیل شده',
                  value: '${FaNum.ofInt(stats.completedAppointments)} نوبت',
                  icon: Icons.assignment_turned_in_rounded,
                  tint: pal.primaryBright,
                  background: pal.surfaceAlt.withValues(alpha: 0.55),
                  borderColor: pal.borderStrong.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  label: 'درآمد تخمینی',
                  value: Fmt.compactMoneyShort(stats.monthRevenue),
                  icon: Icons.account_balance_wallet_rounded,
                  tint: pal.success,
                  background: pal.successSoft,
                  borderColor: pal.success.withValues(alpha: 0.28),
                  valueSize: 13.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          PerformanceChart(data: stats.weekdayPerformance, height: 208),
        ],
      ),
    );
  }
}
