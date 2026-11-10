import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/motion/primitives/pop_in.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_summary/rewards_summary_bloc.dart';

/// Pill width as a fraction of screen width.
const double _pillWidthFraction = 0.26;

/// Pill height as a fraction of screen width.
const double _pillHeightFraction = 0.1;

/// White label size on the orange rewards pill.
const double _pillLabelSize = 15;

/// Title with an edge-flush pending-rewards pill.
class RewardsHeader extends StatelessWidget {
  const RewardsHeader({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: context.spacing.xl),
    child: Row(
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
    ),
  );
}

class _RewardsPill extends StatelessWidget {
  const _RewardsPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final radius = context.radius;
    final spacing = context.spacing;
    return SizedBox(
      width: width * _pillWidthFraction,
      height: width * _pillHeightFraction,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.highlight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius.pill),
            bottomLeft: Radius.circular(radius.pill),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: spacing.md, right: spacing.sm),
          child: Center(child: _RewardsPillLabel(count: count)),
        ),
      ),
    );
  }
}

class _RewardsPillLabel extends StatelessWidget {
  const _RewardsPillLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.rewardsBadge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.subtitle.copyWith(
              color: colors.surface,
              fontSize: _pillLabelSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: context.spacing.sm),
        _CountBadge(count: count),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox.square(
      dimension: context.iconSizes.md,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            count.toString(),
            style: context.typography.bodyStrong.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
