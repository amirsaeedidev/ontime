import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/dashboard_stats.dart';

/// نمودار درآمد ماهانه با fl_chart (میله‌ای گرد + گرادیان).
class RevenueBarChart extends StatelessWidget {
  const RevenueBarChart({super.key, required this.data, this.height = 190});

  final List<RevenuePoint> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    if (data.isEmpty) return SizedBox(height: height);
    final maxValue = data.map((d) => d.value.toDouble()).reduce((a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 1000.0 : maxValue * 1.25;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => pal.surfaceHigh,
              tooltipRoundedRadius: 10,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${data[group.x].label}\n${Fmt.compactMoney(rod.toY)}',
                TextStyle(color: pal.textPrimary, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Lalezar'),
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (value) => FlLine(
              color: pal.textPrimary.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[index].label,
                      style: TextStyle(fontSize: 9.5, color: pal.textMuted, fontFamily: 'Lalezar'),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value.toDouble(),
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    gradient: LinearGradient(
                      colors: [pal.primary, pal.primaryBright],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: pal.surfaceAlt,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// نمودار خطی روند درآمد.
class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({super.key, required this.data, this.height = 180});

  final List<RevenuePoint> data;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    if (data.isEmpty) return SizedBox(height: height);
    final maxValue = data.map((d) => d.value.toDouble()).reduce((a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 1000.0 : maxValue * 1.3;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (value) => FlLine(
              color: pal.textPrimary.withValues(alpha: 0.05),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[index].label,
                      style: TextStyle(fontSize: 9.5, color: pal.textMuted, fontFamily: 'Lalezar'),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => pal.surfaceHigh,
              tooltipRoundedRadius: 10,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    Fmt.compactMoney(spot.y),
                    TextStyle(color: pal.textPrimary, fontSize: 11, fontFamily: 'Lalezar', fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].value.toDouble())],
              isCurved: true,
              curveSmoothness: 0.28,
              barWidth: 2.6,
              gradient: LinearGradient(colors: [pal.primary, pal.primaryBright]),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3.2,
                  color: pal.background,
                  strokeWidth: 2,
                  strokeColor: pal.primaryBright,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [pal.primary.withValues(alpha: 0.28), pal.primary.withValues(alpha: 0.0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// نمودار دایره‌ای وضعیت نوبت‌ها.
class StatusDonut extends StatelessWidget {
  const StatusDonut({super.key, required this.counts, this.size = 150});

  final Map<String, int> counts;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final colors = [pal.success, pal.info, pal.accentGlow, pal.danger, pal.warning];
    final entries = counts.entries.where((e) => e.value > 0).toList();
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    if (entries.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: Text('داده‌ای نیست', style: TextStyle(fontSize: 11, color: pal.textMuted))),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: size * 0.30,
              startDegreeOffset: -90,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value.toDouble(),
                    color: colors[i % colors.length],
                    radius: size * 0.16,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FaNum.ofInt(total),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: pal.textPrimary),
              ),
              Text('نوبت', style: TextStyle(fontSize: 9.5, color: pal.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
