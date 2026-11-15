import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/jalali.dart';
import '../../../../core/widgets/activity_tile.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../data/models/activity_log.dart';
import '../../../../data/models/enums.dart';
import '../providers/activity_provider.dart';

/// گزارش فعالیت‌های سیستم با فیلتر نوع رویداد.
class ActivityLogsPage extends StatefulWidget {
  const ActivityLogsPage({super.key});

  @override
  State<ActivityLogsPage> createState() => _ActivityLogsPageState();
}

class _ActivityLogsPageState extends State<ActivityLogsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    final pal = context.pal;

    final grouped = <String, List<ActivityLog>>{};
    for (final log in provider.logs) {
      final key = JalaliDate.fromDateTime(log.createdAt).long;
      grouped.putIfAbsent(key, () => []).add(log);
    }

    return PageScaffold(
      title: 'گزارش فعالیت‌ها',
      subtitle: 'ردگیری همه رویدادهای سیستم',
      icon: Icons.history_rounded,
      actions: [
        SoftButton(label: 'بازآوری', icon: Icons.refresh_rounded, onTap: provider.load),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchField(
                  controller: _searchController,
                  hint: 'جست‌وجو در عنوان یا توضیح رویداد...',
                  onChanged: provider.search,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _TypeChip(
                        label: 'همه رویدادها',
                        selected: provider.type == null,
                        onTap: () => provider.filterType(null),
                      ),
                      for (final type in ActivityType.values) ...[
                        const SizedBox(width: 6),
                        _TypeChip(
                          label: type.label,
                          icon: type.icon,
                          color: type.color,
                          selected: provider.type == type,
                          onTap: () => provider.filterType(type),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (provider.loading)
            const LoadingState()
          else if (provider.logs.isEmpty)
            const EmptyState(
              title: 'رویدادی یافت نشد',
              description: 'فیلتر نوع رویداد یا عبارت جست‌وجو را تغییر دهید.',
              icon: Icons.history_toggle_off_rounded,
            )
          else
            for (final entry in grouped.entries) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: SectionHeader(title: entry.key)),
                        const SizedBox(width: 8),
                        CountPill(value: entry.value.length),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final log in entry.value) ...[
                      ActivityTile(log: log),
                      if (log != entry.value.last)
                        Divider(color: pal.border.withValues(alpha: 0.5), height: 1),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 4),
          Text(
            'آخرین به‌روزرسانی: ${Fmt.time(DateTime.now().hour, DateTime.now().minute)}',
            style: TextStyle(fontSize: 10, color: pal.textMuted),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final tint = color ?? pal.primaryBright;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? tint.withValues(alpha: 0.18) : pal.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: selected ? tint : pal.border),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: tint),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? pal.textPrimary : pal.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
