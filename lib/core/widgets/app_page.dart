import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../app/theme/app_tokens.dart';
import 'app_buttons.dart';
import 'app_top_bar.dart';

/// پوسته استاندارد صفحه‌ها: نوار بالای موبایل، سربرگ دسکتاپ و محتوای واکنش‌گرا.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions = const [],
    this.child,
    this.showLogo = false,
    this.onClose,
    this.showBackButton = false,
    this.mobileActions = const [],
    this.bottomBar,
    this.scrollable = true,
    this.padding,
    this.header,
    this.floatingAction,
    this.mobileHeader,
    this.onHeaderAction,
    this.headerActionLabel,
    this.centerTitle = false,
    this.onBell,
    this.onProfile,
    this.hasNotification = true,
    this.onMenu,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> actions;
  final Widget? child;
  final bool showLogo;
  final VoidCallback? onClose;
  final bool showBackButton;
  final List<Widget> mobileActions;
  final PreferredSizeWidget? bottomBar;
  final bool scrollable;
  final EdgeInsets? padding;
  final Widget? header;
  final Widget? floatingAction;
  final Widget? mobileHeader;
  final VoidCallback? onHeaderAction;
  final String? headerActionLabel;
  final bool centerTitle;
  final VoidCallback? onBell;
  final VoidCallback? onProfile;
  final bool hasNotification;
  final VoidCallback? onMenu;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.tablet;
    final hPad = padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding(width));

    return Scaffold(
      backgroundColor: pal.background,
      floatingActionButton: floatingAction,
      bottomNavigationBar: bottomBar,
      body: Column(
        children: [
          if (!isDesktop)
            AppTopBar(
              title: title,
              subtitle: subtitle,
              showLogo: showLogo,
              onClose: onClose,
              centerTitle: centerTitle,
              onBell: onBell,
              onProfile: onProfile,
              hasNotification: hasNotification,
              onMenu: onMenu,
              leading: showBackButton
                  ? CircleIconButton(
                      icon: Icons.arrow_forward_rounded,
                      size: 40,
                      onTap: () => context.canPop() ? context.pop() : context.go('/dashboard'),
                    )
                  : leading,
              actions: [
                ...mobileActions,
                if (headerActionLabel != null)
                  _HeaderTextAction(label: headerActionLabel!, onTap: onHeaderAction),
              ],
            ),
          Expanded(
            child: scrollable
                ? Scrollbar(
                    thumbVisibility: false,
                    thickness: 3,
                    radius: const Radius.circular(4),
                    child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: isDesktop ? 22 : 16, bottom: 28),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: Breakpoints.contentMaxWidth(width)),
                        child: Padding(
                          padding: hPad,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (isDesktop) ...[
                                header ??
                                    DesktopPageHeader(
                                      title: title,
                                      subtitle: subtitle,
                                      icon: icon,
                                      actions: actions,
                                    ),
                                const SizedBox(height: 18),
                              ] else if (mobileHeader != null) ...[
                                mobileHeader!,
                                const SizedBox(height: 14),
                              ],
                              if (child != null) child!,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: Breakpoints.contentMaxWidth(width)),
                      child: Padding(
                        padding: hPad,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isDesktop) ...[
                              header ??
                                  DesktopPageHeader(
                                    title: title,
                                    subtitle: subtitle,
                                    icon: icon,
                                    actions: actions,
                                  ),
                              const SizedBox(height: 18),
                            ] else if (mobileHeader != null) ...[
                              mobileHeader!,
                              const SizedBox(height: 14),
                            ],
                            Expanded(child: child ?? const SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTextAction extends StatelessWidget {
  const _HeaderTextAction({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 36),
      ),
      child: Text(label, style: TextStyle(fontSize: 11.5, color: pal.primaryBright, fontWeight: FontWeight.w600)),
    );
  }
}

/// ستون واکنش‌گرا (۱ تا ۴ ستون بر اساس عرض).
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 240,
    this.spacing = 12,
    this.runSpacing = 12,
    this.maxColumns = 4,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double runSpacing;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = (width / minItemWidth).floor().clamp(1, maxColumns);
        final itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (final child in children) SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// فاصله عمودی استاندارد بین بخش‌ها.
class Gap extends StatelessWidget {
  const Gap(this.height, {super.key});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}
