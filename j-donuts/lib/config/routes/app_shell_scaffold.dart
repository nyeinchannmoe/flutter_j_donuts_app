import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/sliding_pill_indicator.dart';

/// One bottom navigation destination.
class ShellDestination {
  const ShellDestination({required this.icon, required this.label});

  final IconData icon;
  final String Function(BuildContext context) label;
}

/// Bottom navigation in branch order: Home, Menu, Rewards, Orders, Settings.
final List<ShellDestination> shellDestinations = [
  ShellDestination(icon: Icons.home_rounded, label: (c) => c.l10n.navHome),
  ShellDestination(
    icon: Icons.restaurant_menu_rounded,
    label: (c) => c.l10n.navMenu,
  ),
  ShellDestination(
    icon: Icons.card_giftcard_rounded,
    label: (c) => c.l10n.navRewards,
  ),
  ShellDestination(
    icon: Icons.receipt_long_rounded,
    label: (c) => c.l10n.navOrders,
  ),
  ShellDestination(
    icon: Icons.settings_rounded,
    label: (c) => c.l10n.navSettings,
  ),
];

class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onSelected(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: ShellNavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onSelected: _onSelected,
    ),
  );
}

/// Bottom navigation bar for the five-tab shell.
class ShellNavigationBar extends StatelessWidget {
  const ShellNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static Key destinationKey(int index) => ValueKey('shell_destination_$index');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: context.shadows.floating,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(context.spacing.sm),
          child: Stack(
            children: [
              Positioned.fill(child: _indicator(context)),
              _items(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _items() => Row(
    children: [
      for (var i = 0; i < shellDestinations.length; i++)
        Expanded(
          child: _ShellItem(
            key: destinationKey(i),
            destination: shellDestinations[i],
            selected: i == selectedIndex,
            onTap: () => onSelected(i),
          ),
        ),
    ],
  );

  Widget _indicator(BuildContext context) => SlidingPillIndicator(
    slotCount: shellDestinations.length,
    selectedIndex: selectedIndex,
    pill: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: context.radius.pillAll,
      ),
    ),
  );
}

class _ShellItem extends StatelessWidget {
  const _ShellItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.textPrimary
        : context.colors.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.radius.pillAll,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(destination.icon, color: color, size: context.iconSizes.md),
              Text(
                destination.label(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.caption.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
