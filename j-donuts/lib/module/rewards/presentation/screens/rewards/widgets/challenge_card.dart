import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/primitives/pulse_attention.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({required this.challenge, super.key});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: context.radius.lgAll,
      boxShadow: context.shadows.card,
    ),
    child: Padding(
      padding: EdgeInsets.all(context.spacing.md),
      child: Row(
        children: [
          _thumbnail(context),
          SizedBox(width: context.spacing.md),
          Expanded(child: _ChallengeText(challenge: challenge)),
          PulseAttention(
            active: challenge.isComplete && !challenge.claimed,
            child: _EarnChip(points: challenge.rewardPoints),
          ),
        ],
      ),
    ),
  );

  Widget _thumbnail(BuildContext context) => ClipRRect(
    borderRadius: context.radius.mdAll,
    child: SizedBox.square(
      dimension: context.iconSizes.xl,
      child: AppImage(image: AssetImageRef(challenge.imageAsset)),
    ),
  );
}

class _ChallengeText extends StatelessWidget {
  const _ChallengeText({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.spacing.xs,
      children: [
        Text(challenge.title, style: context.typography.bodyStrong),
        ClipRRect(
          borderRadius: context.radius.pillAll,
          child: LinearProgressIndicator(
            value: challenge.progressFraction,
            minHeight: context.spacing.sm,
            backgroundColor: colors.surfaceMuted,
            color: challenge.isComplete ? colors.success : colors.primary,
          ),
        ),
        Text(
          context.l10n.challengeProgress(
            challenge.progressCurrent,
            challenge.progressTarget,
          ),
          style: context.typography.caption.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _EarnChip extends StatelessWidget {
  const _EarnChip({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: context.spacing.md),
      child: Column(
        children: [
          Text(
            context.l10n.challengeEarn,
            style: context.typography.label.copyWith(color: colors.accent),
          ),
          Text(
            context.l10n.challengePoints(MmkFormatter.amount(points)),
            style: context.typography.bodyStrong,
          ),
        ],
      ),
    );
  }
}
