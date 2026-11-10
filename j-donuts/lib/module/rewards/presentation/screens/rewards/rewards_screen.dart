import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/points_summary.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/rewards_header.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/rewards_tabs.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/tier_ladder.dart';

/// Ring bottom → pill center gap as a fraction of screen width.
const double _ringToPillCenterFraction = 0.155;

/// Ladder column ends before the ring's left edge.
const double _ladderMaxWidthFraction = 0.41;

/// Rewards: points ring, tier ladder and the challenge and gift tabs.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pillHeight = width * rewardsTabPillHeightFraction;
    final halfPill = pillHeight / 2;
    final gapAfterRing = width * _ringToPillCenterFraction - halfPill;
    final spacing = context.spacing;
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        bottom: false,
        child: StaggeredEntrance(
          itemCount: 3,
          child: CustomScrollView(
            clipBehavior: Clip.none,
            slivers: [
              const _HeaderSliver(),
              _HeroSliver(bottomGap: gapAfterRing),
              SliverFillRemaining(
                hasScrollBody: false,
                child: _SplitSection(
                  halfPill: halfPill,
                  contentTop: halfPill + spacing.lg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSliver extends StatelessWidget {
  const _HeaderSliver();

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: StaggeredItem(
      index: 0,
      child: Padding(
        padding: EdgeInsets.only(top: context.spacing.lg),
        child: const RewardsHeader(),
      ),
    ),
  );
}

class _HeroSliver extends StatelessWidget {
  const _HeroSliver({required this.bottomGap});

  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final spacing = context.spacing;
    final diameter = width * rewardsRingRadiusFraction * 2;
    final ringLeft = width * rewardsRingCenterFromLeftFraction - diameter / 2;
    final ladderWidth = width * _ladderMaxWidthFraction;
    return SliverToBoxAdapter(
      child: StaggeredItem(
        index: 1,
        child: Padding(
          padding: EdgeInsets.only(top: spacing.lg, bottom: bottomGap),
          child: SizedBox(
            height: diameter,
            width: width,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: spacing.xl,
                  width: ladderWidth - spacing.xl,
                  top: 0,
                  child: const TierLadder(),
                ),
                Positioned(
                  left: ringLeft,
                  top: 0,
                  width: diameter,
                  height: diameter,
                  child: const PointsSummary(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitSection extends StatelessWidget {
  const _SplitSection({required this.halfPill, required this.contentTop});

  final double halfPill;
  final double contentTop;

  @override
  Widget build(BuildContext context) => StaggeredItem(
    index: 2,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: halfPill),
            child: ColoredBox(color: context.colors.background),
          ),
        ),
        _SplitBody(contentTop: contentTop),
      ],
    ),
  );
}

class _SplitBody extends StatelessWidget {
  const _SplitBody({required this.contentTop});

  final double contentTop;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: contentTop,
          child: const Align(
            alignment: Alignment.topCenter,
            child: RewardsTabPills(),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: spacing.xl,
            right: spacing.xl,
            bottom: spacing.xxxl,
          ),
          child: const RewardsTabBody(),
        ),
      ],
    );
  }
}
