import 'package:flutter/material.dart';

/// یک مقصد ناوبری در سایدبار/ناوبری پایین.
class NavDestination {
  const NavDestination({
    required this.label,
    required this.icon,
    required this.route,
    this.activeIcon,
    this.shortLabel,
  });

  final String label;
  final IconData icon;
  final String route;
  final IconData? activeIcon;
  final String? shortLabel;

  IconData get iconResolved => activeIcon ?? icon;
}

const List<NavDestination> appDestinations = [
  NavDestination(label: 'پیشخوان', icon: Icons.grid_view_rounded, activeIcon: Icons.dashboard_rounded, route: '/dashboard'),
  NavDestination(label: 'نوبت‌ها', icon: Icons.event_note_rounded, activeIcon: Icons.event_available_rounded, route: '/appointments'),
  NavDestination(label: 'تقویم', icon: Icons.calendar_month_rounded, activeIcon: Icons.calendar_month_rounded, route: '/calendar'),
  NavDestination(label: 'مشتریان', icon: Icons.people_alt_outlined, activeIcon: Icons.people_alt_rounded, route: '/customers'),
  NavDestination(label: 'خدمات', icon: Icons.content_cut_rounded, activeIcon: Icons.content_cut_rounded, route: '/services'),
  NavDestination(label: 'پرسنل', icon: Icons.badge_outlined, activeIcon: Icons.badge_rounded, route: '/employees'),
  NavDestination(label: 'پیامک', icon: Icons.sms_outlined, activeIcon: Icons.sms_rounded, route: '/sms'),
  NavDestination(label: 'گزارش‌ها', icon: Icons.insights_outlined, activeIcon: Icons.insights_rounded, route: '/reports'),
  NavDestination(label: 'فعالیت‌ها', icon: Icons.history_rounded, activeIcon: Icons.history_toggle_off_rounded, route: '/activity'),
  NavDestination(label: 'تنظیمات', icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, route: '/settings'),
];

/// اقلام ناوبری پایین موبایل (مطابق تصویر مرجع).
const List<NavDestination> mobileDestinations = [
  NavDestination(label: 'پیشخوان', icon: Icons.home_outlined, activeIcon: Icons.home_rounded, route: '/dashboard'),
  NavDestination(label: 'نوبت‌ها', icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_month_rounded, route: '/appointments'),
  NavDestination(label: 'مشتریان', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, route: '/customers'),
  NavDestination(label: 'تنظیمات', icon: Icons.tune_rounded, activeIcon: Icons.tune_rounded, route: '/settings'),
];
