import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/motion/primitives/pop_in.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_summary/rewards_summary_bloc.dart';

/// Title with a pill counting pending rewards.
class RewardsHeader extends StatelessWidget {
  const RewardsHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Semantics(
          header: true,
          child: Text(
            context.l10n.rewardsTitle,
            style: context.typography.headline,
          ),
        ),
      ),
      BlocSelector<RewardsSummaryBloc, ViewState<MemberProfile>, int?>(
        selector: (state) => switch (state) {
          ViewData(:final value) => value.pendingRewardsCount,
          _ => null,
        },
        builder: (context, count) => count == null
            ? const SizedBox.shrink()
            : PopIn(child: _RewardsPill(count: count)),
      ),
    ],
  );
}

class _RewardsPill extends StatelessWidget {
  const _RewardsPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.accent,
      borderRadius: context.radius.pillAll,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.xs,
      ),
      child: _label(context),
    ),
  );

  Widget _label(BuildContext context) {
    final color = context.colors.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.spacing.xs,
      children: [
        Text(
          count.toString(),
          style: context.typography.bodyStrong.copyWith(color: color),
        ),
        Text(
          context.l10n.rewardsBadge,
          style: context.typography.label.copyWith(color: color),
        ),
      ],
    );
  }
}
