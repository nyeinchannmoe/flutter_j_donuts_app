import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/widgets/state_views/empty_state_view.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_tabs/rewards_tabs_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/challenges_tab.dart';

/// Pill height as a fraction of screen width.
const double rewardsTabPillHeightFraction = 0.08;

/// Active earn pill width as a fraction of screen width.
const double _earnWidthFraction = 0.4;

/// Gift pill width as a fraction of screen width.
const double _giftWidthFraction = 0.14;

/// Gap between pills as a fraction of screen width.
const double _pillGapFraction = 0.02;

/// Earn / Gift pill pair with a sliding active fill.
class RewardsTabPills extends StatelessWidget {
  const RewardsTabPills({super.key});

  @override
  Widget build(BuildContext context) {
    final index = context.select<RewardsTabsBloc, int>(
      (bloc) => bloc.state.selectedIndex,
    );
    return _SlidingTabPills(selectedIndex: index);
  }
}

/// Challenge / gift body beneath the straddling pills.
class RewardsTabBody extends StatelessWidget {
  const RewardsTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final index = context.select<RewardsTabsBloc, int>(
      (bloc) => bloc.state.selectedIndex,
    );
    return _TabBody(selectedIndex: index);
  }
}

/// Combined pills + body (tests and compact hosts).
class RewardsTabs extends StatelessWidget {
  const RewardsTabs({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Center(child: RewardsTabPills()),
      SizedBox(height: context.spacing.lg),
      const Expanded(child: RewardsTabBody()),
    ],
  );
}

class _SlidingTabPills extends StatelessWidget {
  const _SlidingTabPills({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      final width = constraints.maxWidth.isFinite
          ? math.min(screenWidth, constraints.maxWidth)
          : screenWidth;
      final height = width * rewardsTabPillHeightFraction;
      final earnWidth = width * _earnWidthFraction;
      final giftWidth = width * _giftWidthFraction;
      final gap = width * _pillGapFraction;
      final l10n = context.l10n;
      final colors = context.colors;
      final outline = context.spacing.xxs;
      final duration = context.motion.scaleDuration(MotionTokens.emphasized);
      final activeLeft = selectedIndex == 0 ? 0.0 : earnWidth + gap;
      final activeWidth = selectedIndex == 0 ? earnWidth : giftWidth;
      return SizedBox(
        width: earnWidth + gap + giftWidth,
        height: height,
        child: Stack(
          children: [
            _TrackPill(
              left: 0,
              width: earnWidth,
              height: height,
              color: colors.surfaceMuted,
              outline: outline,
            ),
            _TrackPill(
              left: earnWidth + gap,
              width: giftWidth,
              height: height,
              color: colors.surfaceMuted,
              outline: outline,
            ),
            AnimatedPositioned(
              duration: duration,
              curve: MotionTokens.popOvershoot,
              left: activeLeft,
              width: activeWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: context.radius.pillAll,
                  border: Border.all(color: colors.surface, width: outline),
                ),
              ),
            ),
            Positioned.fill(
              child: Row(
                children: [
                  _TabHit(
                    width: earnWidth,
                    label: l10n.rewardsTabEarn,
                    selected: selectedIndex == 0,
                    onTap: () => context.read<RewardsTabsBloc>().add(
                      const RewardsTabSelected(0),
                    ),
                  ),
                  SizedBox(width: gap),
                  _TabHit(
                    width: giftWidth,
                    label: l10n.rewardsTabGift,
                    selected: selectedIndex == 1,
                    onTap: () => context.read<RewardsTabsBloc>().add(
                      const RewardsTabSelected(1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _TrackPill extends StatelessWidget {
  const _TrackPill({
    required this.left,
    required this.width,
    required this.height,
    required this.color,
    required this.outline,
  });

  final double left;
  final double width;
  final double height;
  final Color color;
  final double outline;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: context.radius.pillAll,
        border: Border.all(color: context.colors.surface, width: outline),
      ),
    ),
  );
}

class _TabHit extends StatelessWidget {
  const _TabHit({
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = selected
        ? context.typography.bodyStrong.copyWith(color: colors.onPrimary)
        : context.typography.body.copyWith(color: colors.textPrimary);
    return SizedBox(
      width: width,
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: context.motion.scaleDuration(MotionTokens.fast),
              curve: MotionTokens.decelerate,
              style: style,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final child = selectedIndex == 0
        ? const ChallengesTab(key: ValueKey(0))
        : const _GiftTab(key: ValueKey(1));
    return AnimatedSwitcher(
      duration: context.motion.scaleDuration(MotionTokens.standard),
      switchInCurve: MotionTokens.decelerate,
      switchOutCurve: MotionTokens.accelerate,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      transitionBuilder: (widget, animation) =>
          _tabTransition(widget, animation, selectedIndex),
      child: child,
    );
  }

  Widget _tabTransition(Widget widget, Animation<double> animation, int index) {
    final begin = index == 0
        ? const Offset(-MotionTokens.tabContentTravel, 0)
        : const Offset(MotionTokens.tabContentTravel, 0);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
          animation,
        ),
        child: widget,
      ),
    );
  }
}

class _GiftTab extends StatelessWidget {
  const _GiftTab({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: EmptyStateView(
      message: context.l10n.rewardsGiftEmpty,
      icon: Icons.card_giftcard_rounded,
    ),
  );
}
