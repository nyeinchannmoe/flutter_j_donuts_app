import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// One bottom navigation destination.
class ShellDestination {
  const ShellDestination({required this.icon, required this.label});

  final IconData icon;
  final String Function(BuildContext context) label;
}

/// Bottom navigation in branch order: Home, Reward, Menu, Orders, Settings.
final List<ShellDestination> shellDestinations = [
  ShellDestination(icon: Icons.home_outlined, label: (c) => c.l10n.navHome),
  ShellDestination(
    icon: Icons.workspace_premium_outlined,
    label: (c) => c.l10n.navRewards,
  ),
  ShellDestination(
    icon: Icons.donut_large_outlined,
    label: (c) => c.l10n.navMenu,
  ),
  ShellDestination(
    icon: Icons.account_balance_wallet_outlined,
    label: (c) => c.l10n.navOrders,
  ),
  ShellDestination(
    icon: Icons.settings_outlined,
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

/// Cyan sheet with a content-sized pink selected pill that slides between tabs.
class ShellNavigationBar extends StatelessWidget {
  const ShellNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static Key destinationKey(int index) => ValueKey<String>('shell-nav-$index');

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.xl)),
        border: Border.all(color: colors.onPrimary),
        boxShadow: context.shadows.floating,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(context.spacing.sm),
          child: _ShellNavTrack(
            selectedIndex: selectedIndex,
            onSelected: onSelected,
          ),
        ),
      ),
    );
  }
}

class _ShellNavTrack extends StatelessWidget {
  const _ShellNavTrack({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Positioned.fill(
        child: _SlidingSelectedPill(
          destination: shellDestinations[selectedIndex],
          selectedIndex: selectedIndex,
          slotCount: shellDestinations.length,
        ),
      ),
      Row(
        children: [
          for (var i = 0; i < shellDestinations.length; i++)
            Expanded(
              child: _ShellNavItem(
                key: ShellNavigationBar.destinationKey(i),
                destination: shellDestinations[i],
                selected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    ],
  );
}

class _SlidingSelectedPill extends StatelessWidget {
  const _SlidingSelectedPill({
    required this.destination,
    required this.selectedIndex,
    required this.slotCount,
  });

  final ShellDestination destination;
  final int selectedIndex;
  final int slotCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return AnimatedAlign(
      alignment: _slotAlignment(selectedIndex, slotCount),
      duration: context.motion.scaleDuration(MotionTokens.standard),
      curve: MotionTokens.emphasizedCurve,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: context.radius.pillAll,
          border: Border.all(color: colors.onPrimary),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          child: _SelectedPillLabel(destination: destination),
        ),
      ),
    );
  }
}

class _SelectedPillLabel extends StatelessWidget {
  const _SelectedPillLabel({required this.destination});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          destination.icon,
          color: colors.onPrimary,
          size: context.iconSizes.md,
        ),
        SizedBox(width: context.spacing.xs),
        Text(
          destination.label(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.label.copyWith(color: colors.onPrimary),
        ),
      ],
    );
  }
}

class _ShellNavItem extends StatelessWidget {
  const _ShellNavItem({
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
    final label = destination.label(context);
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.radius.pillAll,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
          child: Opacity(
            opacity: selected ? _hiddenSlotOpacity : _visibleSlotOpacity,
            child: Icon(
              destination.icon,
              color: context.colors.onPrimary,
              size: context.iconSizes.md,
            ),
          ),
        ),
      ),
    );
  }
}

Alignment _slotAlignment(int index, int slotCount) {
  if (slotCount <= 1) return Alignment.center;
  final x = _alignStart + _alignSpan * index / (slotCount - 1);
  return Alignment(x, 0);
}

const double _alignStart = -1;
const double _alignSpan = 2;
const double _hiddenSlotOpacity = 0;
const double _visibleSlotOpacity = 1;
