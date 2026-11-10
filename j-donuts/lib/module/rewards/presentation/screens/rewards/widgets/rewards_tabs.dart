import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/primitives/sliding_pill_indicator.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/core/widgets/state_views/empty_state_view.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/challenges/challenges_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/challenge_card.dart';

/// Earn and Gift tabs. The selected tab is local view state.
class RewardsTabs extends StatefulWidget {
  const RewardsTabs({super.key});

  @override
  State<RewardsTabs> createState() => _RewardsTabsState();
}

class _RewardsTabsState extends State<RewardsTabs> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TabBar(
          labels: [l10n.rewardsTabEarn, l10n.rewardsTabGift],
          selectedIndex: _selected,
          onSelected: (index) => setState(() => _selected = index),
        ),
        SizedBox(height: context.spacing.lg),
        AnimatedSwitcher(
          duration: context.motion.scaleDuration(MotionTokens.standard),
          child: _selected == 0
              ? const _ChallengesTab(key: ValueKey(0))
              : EmptyStateView(
                  key: const ValueKey(1),
                  message: l10n.rewardsGiftEmpty,
                  icon: Icons.card_giftcard_rounded,
                ),
        ),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: context.radius.pillAll,
    ),
    child: Stack(
      children: [
        Positioned.fill(child: _indicator(context)),
        _labels(),
      ],
    ),
  );

  Widget _indicator(BuildContext context) => SlidingPillIndicator(
    slotCount: labels.length,
    selectedIndex: selectedIndex,
    pill: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: context.radius.pillAll,
      ),
    ),
  );

  Widget _labels() => Row(
    children: [
      for (var i = 0; i < labels.length; i++)
        Expanded(
          child: _TabLabel(
            label: labels[i],
            selected: i == selectedIndex,
            onTap: () => onSelected(i),
          ),
        ),
    ],
  );
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: context.radius.pillAll,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.spacing.md),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.typography.bodyStrong.copyWith(
            color: selected
                ? context.colors.textPrimary
                : context.colors.textSecondary,
          ),
        ),
      ),
    ),
  );
}

class _ChallengesTab extends StatelessWidget {
  const _ChallengesTab({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ChallengesBloc, ViewState<List<Challenge>>>(
        builder: (context, state) => ViewStateBuilder<List<Challenge>>(
          state: state,
          skeleton: SkeletonBlock(height: context.iconSizes.illustration),
          emptyMessage: context.l10n.challengesEmpty,
          onRetry: () =>
              context.read<ChallengesBloc>().add(const ChallengesRetried()),
          builder: (context, challenges) => Column(
            spacing: context.spacing.md,
            children: [
              for (final challenge in challenges)
                ChallengeCard(challenge: challenge),
            ],
          ),
        ),
      );
}
