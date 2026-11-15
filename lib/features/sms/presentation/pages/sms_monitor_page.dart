import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/utils/fa_num.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_inputs.dart';
import '../../../../core/widgets/app_page.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../data/models/enums.dart';
import '../../../../data/models/sms_message.dart';
import '../providers/sms_provider.dart';

/// مانیتورینگ پیامک‌ها با آمار تحویل و وضعیت هر پیام.
class SmsMonitorPage extends StatefulWidget {
  const SmsMonitorPage({super.key});

  @override
  State<SmsMonitorPage> createState() => _SmsMonitorPageState();
}

class _SmsMonitorPageState extends State<SmsMonitorPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SmsProvider>();
    final pal = context.pal;
    final stats = provider.stats;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return PageScaffold(
      title: 'مدیریت پیامک',
      subtitle: 'پایش ارسال، تحویل و وضعیت پیامک‌ها',
      icon: Icons.sms_rounded,
      actions: [
        SoftButton(label: 'قالب‌ها', icon: Icons.article_outlined, onTap: () => context.push('/sms/templates')),
        SolidButton(
          label: 'تنظیمات پنل',
          icon: Icons.settings_rounded,
          height: 42,
          onPressed: () => context.push('/sms/settings'),
        ),
      ],
      mobileActions: [
        CircleIconButton(icon: Icons.article_outlined, size: 38, onTap: () => context.push('/sms/templates')),
        CircleIconButton(icon: Icons.settings_rounded, size: 38, onTap: () => context.push('/sms/settings')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (stats != null)
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 5 : (constraints.maxWidth >= 520 ? 3 : 2);
                final width = (constraints.maxWidth - 10 * (columns - 1)) / columns;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatCard(width: width, label: 'کل پیامک‌ها', value: FaNum.ofInt(stats.total), color: pal.primaryBright, icon: Icons.forum_rounded),
                    _StatCard(width: width, label: 'تحویل شده', value: FaNum.ofInt(stats.delivered), color: pal.success, icon: Icons.mark_email_read_rounded),
                    _StatCard(width: width, label: 'در صف/ارسال', value: FaNum.ofInt(stats.pending + stats.sent), color: pal.warning, icon: Icons.schedule_send_rounded),
                    _StatCard(width: width, label: 'ناموفق', value: FaNum.ofInt(stats.failed), color: pal.danger, icon: Icons.error_outline_rounded),
                    _StatCard(width: width, label: 'اعتبار پنل', value: '${FaNum.ofInt(stats.credit)} پیامک', color: pal.purple, icon: Icons.account_balance_wallet_rounded),
                  ],
                );
              },
            ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchField(
                  controller: _searchController,
                  hint: 'جست‌وجوی شماره، نام یا متن پیامک...',
                  onChanged: provider.search,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PillToggle(
                      options: const ['همه', 'تحویل شده', 'در صف', 'ناموفق'],
                      selectedIndex: switch (provider.statusFilter) {
                        null => 0,
                        SmsStatus.delivered => 1,
                        SmsStatus.pending || SmsStatus.sent => 2,
                        SmsStatus.failed => 3,
                      },
                      dense: true,
                      onChanged: (i) => provider.filterStatus(switch (i) {
                        0 => null,
                        1 => SmsStatus.delivered,
                        2 => SmsStatus.pending,
                        _ => SmsStatus.failed,
                      }),
                    ),
                    SoftButton(label: 'بازآوری', icon: Icons.refresh_rounded, dense: true, onTap: provider.load),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.loading)
                  const LoadingState(compact: true)
                else if (provider.messages.isEmpty)
                  const EmptyState(title: 'پیامکی یافت نشد', description: 'فیلترها را تغییر دهید.', compact: true)
                else if (isDesktop)
                  _SmsTable(messages: provider.messages)
                else
                  for (final message in provider.messages) ...[
                    _SmsTile(message: message),
                    const SizedBox(height: 8),
                  ],
                const SizedBox(height: 10),
                PaginationBar(
                  page: provider.pageNumber,
                  totalPages: provider.page.totalPages,
                  totalItems: provider.page.total,
                  pageSize: provider.page.pageSize,
                  onPageChanged: provider.goToPage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            color: pal.surfaceAlt.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 15, color: pal.primaryBright),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'این گزارش نمونه است؛ در این فاز اتصال به پنل واقعی پیامک انجام نمی‌شود و نرخ تحویل تضمینی نیست.',
                    style: TextStyle(fontSize: 10.5, color: pal.textMuted, height: 1.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.width,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      width: width ?? 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: pal.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, color: color, size: 28, radius: 9),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: pal.textPrimary)),
          Text(label, style: TextStyle(fontSize: 10, color: pal.textMuted)),
        ],
      ),
    );
  }
}

class _SmsTile extends StatelessWidget {
  const _SmsTile({required this.message});

  final SmsMessage message;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      padding: const EdgeInsets.all(12),
      radius: AppRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarBadge(name: message.recipientName, size: 34, color: pal.primaryBright),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.recipientName,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                    ),
                    Text(Fmt.phone(message.phone), style: TextStyle(fontSize: 10.5, color: pal.textMuted)),
                  ],
                ),
              ),
              StatusBadge(label: message.status.label, color: message.status.color, dense: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.content,
            style: TextStyle(fontSize: 11, color: pal.textSecondary, height: 1.8),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetaChip(icon: Icons.local_offer_outlined, label: message.templateLabel),
              _MetaChip(icon: Icons.send_rounded, label: Fmt.jalaliDateTime(message.sentAt ?? message.createdAt)),
              if (message.deliveredAt != null)
                _MetaChip(icon: Icons.done_all_rounded, label: Fmt.clock(message.deliveredAt!), color: pal.success),
            ],
          ),
          if (message.error != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 12, color: pal.danger),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(message.error!, style: TextStyle(fontSize: 10, color: pal.danger)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color ?? pal.textMuted),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 9.5, color: color ?? pal.textMuted)),
      ],
    );
  }
}

class _SmsTable extends StatelessWidget {
  const _SmsTable({required this.messages});

  final List<SmsMessage> messages;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    const flex = [3, 2, 3, 3, 2];
    return Column(
      children: [
        const TableHeaderRow(
          cells: ['گیرنده', 'شماره', 'نوع پیامک', 'تاریخ ارسال', 'وضعیت'],
          flex: flex,
        ),
        for (final message in messages)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: pal.border.withValues(alpha: 0.6))),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: flex[0],
                  child: Text(
                    message.recipientName,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: pal.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: flex[1],
                  child: Text(Fmt.phone(message.phone), style: TextStyle(fontSize: 11, color: pal.textMuted)),
                ),
                Expanded(
                  flex: flex[2],
                  child: Text(message.templateLabel, style: TextStyle(fontSize: 11, color: pal.textSecondary)),
                ),
                Expanded(
                  flex: flex[3],
                  child: Text(
                    Fmt.jalaliDateTime(message.sentAt ?? message.createdAt),
                    style: TextStyle(fontSize: 10.5, color: pal.textMuted),
                  ),
                ),
                Expanded(
                  flex: flex[4],
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: StatusBadge(label: message.status.label, color: message.status.color, dense: true),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
