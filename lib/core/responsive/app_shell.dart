import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../utils/fa_num.dart';
import '../widgets/app_card.dart';
import '../widgets/badges.dart';
import 'nav_destinations.dart';

/// پوسته اصلی برنامه: سایدبار در دسکتاپ/تبلت بزرگ، ناوبری پایین در موبایل.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  int get _index {
    for (var i = 0; i < appDestinations.length; i++) {
      if (location.startsWith(appDestinations[i].route)) return i;
    }
    return 0;
  }

  void _navigate(BuildContext context, String route) {
    if (location == route) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useSidebar = width >= Breakpoints.tablet;

    if (!useSidebar) {
      return Scaffold(
        backgroundColor: context.pal.background,
        body: child,
        bottomNavigationBar: MobileBottomNav(
          currentIndex: _index,
          onSelect: (i) => _navigate(context, appDestinations[i].route),
          onAdd: () => context.push('/appointments/new'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.pal.background,
      body: Row(
        children: [
          AppSidebar(
            currentIndex: _index,
            expanded: width >= Breakpoints.desktop,
            onSelect: (i) => _navigate(context, appDestinations[i].route),
            onAdd: () => context.push('/appointments/new'),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// ناوبری پایین شناور با دکمه میانی (مطابق تصویر مرجع).
class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  // نقشه به تب‌های موبایل: پیشخوان، نوبت‌ها، مشتریان، تنظیمات
  static const List<int> _map = [0, 1, 3, 9];

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      decoration: BoxDecoration(
        color: pal.background,
        border: Border(top: BorderSide(color: pal.border.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 92,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: pal.backgroundAlt,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: pal.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: pal.isDark ? 0.45 : 0.08),
                        blurRadius: 22,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      for (var slot = 0; slot < 5; slot++)
                        Expanded(child: _buildSlot(context, slot)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 36,
                child: _AddButton(onTap: onAdd),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(BuildContext context, int slot) {
    final pal = context.pal;
    if (slot == 2) return const SizedBox.shrink();
    final navIndex = _map[slot < 2 ? slot : slot - 1];
    final dest = appDestinations[navIndex];
    final selected = currentIndex == navIndex;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onSelect(navIndex),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: selected ? pal.primary.withValues(alpha: 0.16) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              selected ? dest.iconResolved : dest.icon,
              size: 21,
              color: selected ? pal.primaryBright : pal.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dest.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? pal.primaryBright : pal.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [pal.primary, pal.primaryBright],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: pal.background, width: 4),
          boxShadow: AppShadows.glow(pal.primary, opacity: 0.45, blur: 22),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

/// سایدبار دسکتاپ.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.expanded,
    required this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final bool expanded;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final settings = context.watch<SettingsProvider>();
    final width = expanded ? 246.0 : 84.0;

    return AnimatedContainer(
      duration: AppDurations.normal,
      width: width,
      decoration: BoxDecoration(
        color: pal.backgroundAlt,
        border: Border(left: BorderSide(color: pal.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: expanded ? 18 : 10, vertical: 18),
              child: Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: pal.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 20),
                  ),
                  if (expanded) ...[
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'ONT',
                                style: TextStyle(
                                  fontFamily: 'Lalezar',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: pal.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: 'IME',
                                style: TextStyle(
                                  fontFamily: 'Lalezar',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: pal.primaryBright,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'مدیریت نوبت‌دهی',
                          style: TextStyle(fontSize: 9.5, color: pal.textMuted),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Divider(color: pal.border, height: 1),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8, vertical: 4),
                children: [
                  for (var i = 0; i < appDestinations.length; i++)
                    _SidebarItem(
                      destination: appDestinations[i],
                      selected: currentIndex == i,
                      expanded: expanded,
                      onTap: () => onSelect(i),
                    ),
                  const SizedBox(height: 14),
                  if (expanded)
                    _BookingLinkCard(onTap: () => context.push('/book'))
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: IconButton(
                        tooltip: 'صفحه رزرو عمومی',
                        onPressed: () => context.push('/book'),
                        icon: Icon(Icons.public_rounded, color: pal.primaryBright),
                      ),
                    ),
                ],
              ),
            ),
            Divider(color: pal.border, height: 1),
            Padding(
              padding: EdgeInsets.all(expanded ? 12 : 8),
              child: expanded
                  ? Row(
                      children: [
                        AvatarBadge(name: settings.ownerName, size: 36, color: pal.primaryBright),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                settings.ownerName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: pal.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                settings.ownerRole,
                                style: TextStyle(fontSize: 10, color: pal.textMuted),
                              ),
                            ],
                          ),
                        ),
                        CountPill(value: settings.totalUnread, icon: Icons.notifications_none_rounded),
                      ],
                    )
                  : Center(child: AvatarBadge(name: settings.ownerName, size: 34, color: pal.primaryBright)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 0, vertical: 11),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(colors: [pal.primary.withValues(alpha: 0.26), pal.primary.withValues(alpha: 0.06)])
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? pal.primary.withValues(alpha: 0.4) : Colors.transparent),
            ),
            child: Row(
              mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? destination.iconResolved : destination.icon,
                  size: 19,
                  color: selected ? pal.primaryBright : pal.textMuted,
                ),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      destination.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? pal.textPrimary : pal.textSecondary,
                      ),
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(color: pal.primaryBright, shape: BoxShape.circle),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingLinkCard extends StatelessWidget {
  const _BookingLinkCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [pal.primary.withValues(alpha: 0.22), pal.purple.withValues(alpha: 0.12)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: pal.primary.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public_rounded, size: 15, color: pal.primaryBright),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'صفحه رزرو عمومی',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: pal.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'ontime.app/book',
              textDirection: TextDirection.ltr,
              style: TextStyle(fontSize: 10, color: pal.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              'مشاهده صفحه مشتری',
              style: TextStyle(fontSize: 10, color: pal.primaryBright, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// نمایش شماره صفحه‌ها برای هدر‌ها.
String faCount(int value) => FaNum.ofInt(value);
