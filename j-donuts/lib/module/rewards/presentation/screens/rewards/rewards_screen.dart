import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/points_summary.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/rewards_header.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/rewards_tabs.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/tier_ladder.dart';

/// Rewards: points ring, tier ladder and the challenge and gift tabs.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  static const List<Widget> _sections = [
    RewardsHeader(),
    PointsSummary(),
    TierLadder(),
    RewardsTabs(),
  ];

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final spacing = context.spacing;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: StaggeredEntrance(
          itemCount: _sections.length,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: LayoutMetrics.maxContentWidth,
              ),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: layout.horizontalGutter,
                  vertical: spacing.lg,
                ),
                itemCount: _sections.length,
                separatorBuilder: (_, _) => SizedBox(height: spacing.xl),
                itemBuilder: (context, index) =>
                    StaggeredItem(index: index, child: _sections[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
