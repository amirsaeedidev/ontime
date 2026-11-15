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
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../data/models/customer.dart';
import '../../../sms/presentation/providers/sms_provider.dart';
import '../providers/customers_provider.dart';

/// فهرست مشتریان — بازسازی صفحه «مشتریان» تصویر مرجع.
class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomersProvider>();
    final sms = context.watch<SmsProvider>();
    final pal = context.pal;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    final smsPill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: pal.surfaceAlt,
        borderRadius: AppRadius.brPill,
        border: Border.all(color: pal.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sms_outlined, size: 13, color: pal.textMuted),
          const SizedBox(width: 4),
          Text(
            'موجودی: ${FaNum.ofInt(sms.stats?.credit ?? 0)} پیامک',
            style: TextStyle(fontSize: 10.5, color: pal.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    return PageScaffold(
      title: 'مشتریان',
      subtitle: 'پایگاه داده مشتریان و سابقه مراجعات',
      icon: Icons.people_alt_rounded,
      actions: [
        if (isDesktop) smsPill,
        SoftButton(label: 'بازآوری', icon: Icons.refresh_rounded, onTap: provider.load),
        SolidButton(
          label: 'افزودن مشتری',
          icon: Icons.person_add_alt_1_rounded,
          height: 42,
          onPressed: () => context.push('/customers/new'),
        ),
      ],
      mobileActions: [
        CircleIconButton(icon: Icons.refresh_rounded, size: 38, onTap: provider.load),
        CircleIconButton(icon: Icons.person_add_alt_1_rounded, size: 38, onTap: () => context.push('/customers/new')),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchField(
            controller: _searchController,
            hint: 'جست‌وجو نام یا شماره...',
            accentBorder: true,
            onChanged: provider.search,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SolidButton(
                  label: 'پیام همگانی',
                  icon: Icons.sms_rounded,
                  color: pal.purple,
                  height: 50,
                  onPressed: () => AppToast.show(context, 'ارسال پیام همگانی در فاز بعدی فعال می‌شود'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SolidButton(
                  label: 'افزودن مشتری',
                  icon: Icons.person_add_alt_1_rounded,
                  gradient: true,
                  height: 50,
                  onPressed: () => context.push('/customers/new'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.loading)
            const LoadingState()
          else if (provider.items.isEmpty)
            const EmptyState(
              title: 'مشتری‌ای یافت نشد',
              description: 'شماره یا نام دیگری را جست‌وجو کنید یا مشتری جدید اضافه کنید.',
              icon: Icons.person_search_rounded,
            )
          else ...[
            for (final customer in provider.items) ...[
              _CustomerCard(
                customer: customer,
                onTap: () => context.push('/customers/${customer.id}'),
                onContact: () => context.push('/customers/${customer.id}'),
              ),
              const SizedBox(height: 10),
            ],
            PaginationBar(
              page: provider.pageNumber,
              totalPages: provider.page.totalPages,
              totalItems: provider.page.total,
              pageSize: provider.page.pageSize,
              onPageChanged: provider.goToPage,
            ),
          ],
          const SizedBox(height: 12),
          AppCard(
            color: pal.surfaceAlt.withValues(alpha: 0.4),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 15, color: pal.primaryBright),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'شاخص پایبندی مشتری بر اساس حضور، لغو و عدم حضور محاسبه می‌شود.',
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

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.onTap, this.onContact});

  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback? onContact;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final accent = [pal.primary, pal.success, pal.purple, pal.info, pal.warning][
        customer.fullName.hashCode.abs() % 5];
    final lastVisit = customer.lastVisitAt == null
        ? 'ندارد'
        : Fmt.jalaliDate(customer.lastVisitAt!);

    return AppCard(
      onTap: onTap,
      radius: AppRadius.lg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              boxShadow: AppShadows.glow(accent, opacity: 0.25, blur: 12),
            ),
            child: Text(
              customer.initials,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.fullName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: pal.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Fmt.phone(customer.phone),
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 11.5, color: pal.textSecondary, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'آخرین مراجعه',
                style: TextStyle(fontSize: 9.5, color: pal.textMuted),
              ),
              const SizedBox(height: 3),
              Text(
                lastVisit,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: lastVisit == 'ندارد' ? pal.primaryBright : pal.success,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onContact,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.person_rounded, size: 20, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
