import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/rewards/domain/entities/tier.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_summary/rewards_summary_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/tier_ladder/tier_ladder_bloc.dart';

/// Tier list captioned relative to the member's current tier. The member
/// comes from RewardsSummaryBloc; the two Blocs stay independent.
class TierLadder extends StatelessWidget {
  const TierLadder({super.key});

  @override
  Widget build(BuildContext context) {
    final member = context.select<RewardsSummaryBloc, MemberProfile?>(
      (bloc) => switch (bloc.state) {
        ViewData(:final value) => value,
        _ => null,
      },
    );
    return BlocBuilder<TierLadderBloc, ViewState<List<Tier>>>(
      builder: (context, state) => ViewStateBuilder<List<Tier>>(
        state: state,
        skeleton: SkeletonBlock(height: context.iconSizes.illustration),
        emptyMessage: context.l10n.emptyTitle,
        onRetry: () =>
            context.read<TierLadderBloc>().add(const TierLadderRetried()),
        builder: (context, tiers) => Column(
          spacing: context.spacing.sm,
          children: [
            for (final tier in tiers) _TierRow(tier: tier, member: member),
          ],
        ),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.member});

  final Tier tier;
  final MemberProfile? member;

  String? _caption(BuildContext context) {
    final l10n = context.l10n;
    final current = member;
    if (current == null) return null;
    final rank = current.tierRank;
    if (tier.rank < rank) return l10n.tierPassed;
    if (tier.rank == rank) return l10n.tierCurrent;
    if (tier.rank == rank + 1) {
      return l10n.tierRemaining(
        MmkFormatter.amount(current.pointsToNextTier),
        tier.name,
      );
    }
    return l10n.tierFuture;
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        Icons.workspace_premium_rounded,
        color: context.colors.tierColor(tier.rank),
        size: context.iconSizes.lg,
      ),
      SizedBox(width: context.spacing.md),
      Expanded(child: _texts(context)),
    ],
  );

  Widget _texts(BuildContext context) {
    final isCurrent = member?.tierRank == tier.rank;
    final caption = _caption(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tier.name,
          style: isCurrent
              ? context.typography.subtitle
              : context.typography.body,
        ),
        if (caption != null)
          Text(
            caption,
            style: context.typography.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
      ],
    );
  }
}
