import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/dashboard_stats.dart';
import '../../../../data/models/enums.dart';
import '../providers/reports_provider.dart';
import '../widgets/revenue_chart.dart';

/// گزارش درآمد، عملکرد پرسنل و ترکیب خدمات.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();
    final pal = context.pal;

    return PageScaffold(
      title: 'گزارش‌ها و تحلیل',
      subtitle: 'عملکرد مالی و آماری مجموعه',
      icon: Icons.insights_rounded,
      actions: [
        PillToggle(
          options: const ['۳ ماه', '۶ ماه', '۱۲ ماه'],
          selectedIndex: switch (provider.months) {
            3 => 0,
            6 => 1,
            _ => 2,
          },
          dense: true,
          onChanged: (i) => provider.setMonths([3, 6, 12][i]),
        ),
      ],
      child: provider.loading
          ? const LoadingState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricCard(
                      label: 'درآمد بازه',
                      value: Fmt.compactMoney(provider.totalRevenue),
                      icon: Icons.payments_rounded,
                      color: pal.success,
                    ),
                    _MetricCard(
                      label: 'میانگین ماهانه',
                      value: Fmt.compactMoney(provider.averageRevenue),
                      icon: Icons.show_chart_rounded,
                      color: pal.primaryBright,
                    ),
                    _MetricCard(
                      label: 'بهترین ماه',
                      value: Fmt.compactMoney(provider.bestMonth),
                      icon: Icons.emoji_events_rounded,
                      color: pal.warning,
                    ),
                    _MetricCard(
                      label: 'کل نوبت‌ها',
                      value: FaNum.ofInt(provider.totalAppointments),
                      icon: Icons.event_note_rounded,
                      color: pal.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'درآمد ماهانه', subtitle: '${FaNum.ofInt(provider.months)} ماه اخیر'),
                      const SizedBox(height: 14),
                      RevenueBarChart(data: provider.revenueSeries, height: 190),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'روند رشد درآمد'),
                      const SizedBox(height: 14),
                      RevenueLineChart(data: provider.revenueSeries, height: 180),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    final statusCard = AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'توزیع وضعیت نوبت‌ها'),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              StatusDonut(counts: provider.statusCounts, size: 130),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: [
                                    for (final status in AppointmentStatus.values)
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
                                              ),
                                            ),
                                            Text(
                                              FaNum.ofInt(provider.statusCounts[status.label] ?? 0),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: pal.textPrimary,
                                              ),
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

                    final employeeCard = AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'درآمد به تفکیک پرسنل'),
                          const SizedBox(height: 12),
                          _RankedList(
                            items: provider.employeeRevenue.entries
                                .map((e) => RevenuePoint(label: e.key, value: e.value))
                                .toList()
                              ..sort((a, b) => b.value.compareTo(a.value)),
                            color: pal.primaryBright,
                          ),
                        ],
                      ),
                    );

                    final serviceCard = AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'پرفروش‌ترین خدمات'),
                          const SizedBox(height: 12),
                          _RankedList(items: provider.serviceRevenue, color: pal.success),
                        ],
                      ),
                    );

                    if (!wide) {
                      return Column(
                        children: [
                          statusCard,
                          const SizedBox(height: 12),
                          employeeCard,
                          const SizedBox(height: 12),
                          serviceCard,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: statusCard),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: Column(children: [employeeCard, const SizedBox(height: 12), serviceCard]),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: pal.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, color: color, size: 30, radius: 9),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: pal.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: TextStyle(fontSize: 10, color: pal.textMuted)),
        ],
      ),
    );
  }
}

class _RankedList extends StatelessWidget {
  const _RankedList({required this.items, required this.color});

  final List<RevenuePoint> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    if (items.isEmpty) {
      return const EmptyState(compact: true, title: 'داده‌ای موجود نیست', description: '');
    }
    final max = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        FaNum.ofInt(i + 1),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        items[i].label,
                        style: TextStyle(fontSize: 11.5, color: pal.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      Fmt.compactMoney(items[i].value),
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: pal.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: max == 0 ? 0 : items[i].value / max,
                    minHeight: 5,
                    backgroundColor: pal.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
