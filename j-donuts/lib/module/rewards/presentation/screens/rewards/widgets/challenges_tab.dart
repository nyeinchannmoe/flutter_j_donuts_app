import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/challenges/challenges_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/challenge_card.dart';

/// Earn-tab challenge list; height comes from cards (outer scroll owns motion).
class ChallengesTab extends StatelessWidget {
  const ChallengesTab({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ChallengesBloc, ViewState<List<Challenge>>>(
        builder: (context, state) => ViewStateBuilder<List<Challenge>>(
          state: state,
          skeleton: SkeletonBlock(height: context.iconSizes.illustration),
          emptyMessage: context.l10n.challengesEmpty,
          onRetry: () =>
              context.read<ChallengesBloc>().add(const ChallengesRetried()),
          builder: (context, challenges) => StaggeredEntrance(
            itemCount: challenges.length,
            child: Column(
              spacing: context.spacing.lg,
              children: [
                for (var i = 0; i < challenges.length; i++)
                  StaggeredItem(
                    index: i,
                    child: ChallengeCard(challenge: challenges[i]),
                  ),
              ],
            ),
          ),
        ),
      );
}
