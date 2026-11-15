import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/activity_tile.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../data/models/activity_log.dart';
import '../../../../data/models/dashboard_stats.dart';
import '../../../../data/models/enums.dart';
import '../../../reports/presentation/widgets/revenue_chart.dart';

/// ردیف شاخص‌های کلیدی (تعداد نوبت امروز، درآمد، مشتریان، پرسنل).
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.stats, this.compact = false});

  final DashboardStats stats;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final items = [
      _Kpi(label: 'کل نوبت‌ها', value: FaNum.ofInt(stats.totalAppointments), icon: Icons.event_note_rounded, color: pal.primaryBright),
      _Kpi(label: 'نوبت امروز', value: FaNum.ofInt(stats.todayAppointments), icon: Icons.today_rounded, color: pal.accentGlow),
      _Kpi(label: 'درآمد کل', value: Fmt.compactMoney(stats.totalRevenue), icon: Icons.account_balance_wallet_rounded, color: pal.success),
      _Kpi(label: 'مشتریان', value: FaNum.ofInt(stats.totalCustomers), icon: Icons.people_alt_rounded, color: pal.purple),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 520 ? 2 : 2);
        final spacing = compact ? 8.0 : 10.0;
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: AppCard(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 10 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconTile(icon: item.icon, color: item.color, size: compact ? 26 : 30, radius: 9),
                          const Spacer(),
                          Icon(Icons.trending_up_rounded, size: 12, color: pal.success),
                        ],
                      ),
                      SizedBox(height: compact ? 8 : 10),
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 13 : 15,
                          fontWeight: FontWeight.w800,
                          color: pal.textPrimary,
                        ),
                      ),
                      Text(item.label, style: TextStyle(fontSize: 10, color: pal.textMuted)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Kpi {
  const _Kpi({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

/// دسترسی سریع به اقدامات اصلی.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final actions = [
      ('نوبت جدید', Icons.add_rounded, pal.primaryBright, '/appointments/new'),
      ('مشتری جدید', Icons.person_add_alt_1_rounded, pal.success, '/customers/new'),
      ('خدمت جدید', Icons.content_cut_rounded, pal.purple, '/services/new'),
      ('تقویم', Icons.calendar_month_rounded, pal.accentGlow, '/calendar'),
      ('گزارش‌ها', Icons.insights_rounded, pal.warning, '/reports'),
      ('صفحه رزرو', Icons.public_rounded, pal.info, '/book'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final action in actions) ...[
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => context.push(action.$4),
              child: Container(
                width: 86,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: pal.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: pal.border),
                ),
                child: Column(
                  children: [
                    IconTile(icon: action.$2, color: action.$3, size: 34, radius: 11),
                    const SizedBox(height: 8),
                    Text(
                      action.$1,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: pal.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// کارت آمار وضعیت نوبت‌ها با نمودار دایره‌ای.
class StatusBreakdownCard extends StatelessWidget {
  const StatusBreakdownCard({super.key, required this.counts});

  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final statuses = AppointmentStatus.values;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'وضعیت نوبت‌ها', subtitle: 'بر اساس بازه انتخاب‌شده'),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusDonut(counts: counts, size: 128),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    for (final status in statuses)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                status.label,
                                style: TextStyle(fontSize: 10.5, color: pal.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              FaNum.ofInt(counts[status.label] ?? 0),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: pal.textPrimary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// کارت درآمد ماهانه.
class RevenueCard extends StatelessWidget {
  const RevenueCard({super.key, required this.data, this.showHeaderAction = true});

  final List<RevenuePoint> data;
  final bool showHeaderAction;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final total = data.fold<num>(0, (sum, p) => sum + p.value);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'روند درآمد',
            subtitle: 'شش ماه اخیر',
            actionLabel: showHeaderAction ? 'گزارش کامل' : null,
            onAction: () => context.push('/reports'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.payments_rounded, size: 16, color: pal.success),
              const SizedBox(width: 6),
              Text(
                Fmt.money(total),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: pal.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RevenueBarChart(data: data, height: 160),
        ],
      ),
    );
  }
}

/// کارت فعالیت‌های اخیر.
class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key, required this.logs, this.maxItems = 4});

  final List<ActivityLog> logs;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'فعالیت‌های اخیر',
            actionLabel: 'مشاهده همه',
            onAction: () => context.push('/activity'),
          ),
          const SizedBox(height: 6),
          for (final log in logs.take(maxItems)) ActivityTile(log: log, dense: true),
        ],
      ),
    );
  }
}
