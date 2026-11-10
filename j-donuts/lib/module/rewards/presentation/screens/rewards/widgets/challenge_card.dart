import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/primitives/pulse_attention.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/core/widgets/buttons/pressable_scale.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/painters/donut_quarter_clipper.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/challenge_coffee_art.dart';

/// Desaturate-and-lighten matrix for incomplete donut quarters.
const ColorFilter _washedDonutFilter = ColorFilter.matrix(<double>[
  0.35,
  0.45,
  0.1,
  0,
  40,
  0.35,
  0.45,
  0.1,
  0,
  40,
  0.35,
  0.45,
  0.1,
  0,
  40,
  0,
  0,
  0,
  1,
  0,
]);

const int _artFlex = 28;
const int _textFlex = 72;

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({required this.challenge, super.key});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final claimable = challenge.isComplete && !challenge.claimed;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.xlAll,
        boxShadow: context.shadows.card,
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          children: [
            Expanded(
              flex: _artFlex,
              child: _ChallengeArt(challenge: challenge),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              flex: _textFlex,
              child: _ChallengeBody(
                challenge: challenge,
                claimable: claimable,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeBody extends StatelessWidget {
  const _ChallengeBody({required this.challenge, required this.claimable});

  final Challenge challenge;
  final bool claimable;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge.title,
          maxLines: 3,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: context.typography.bodyStrong,
        ),
        SizedBox(height: spacing.xs),
        Text(
          context.l10n.challengeProgress(
            challenge.progressCurrent,
            challenge.progressTarget,
          ),
          style: context.typography.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: spacing.sm),
        _EarnRow(challenge: challenge, claimable: claimable),
      ],
    );
  }
}

class _EarnRow extends StatelessWidget {
  const _EarnRow({required this.challenge, required this.claimable});

  final Challenge challenge;
  final bool claimable;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        child: PulseAttention(
          active: claimable,
          child: _EarnButton(active: claimable),
        ),
      ),
      SizedBox(width: context.spacing.sm),
      Flexible(
        child: Text(
          context.l10n.challengePoints(
            MmkFormatter.amount(challenge.rewardPoints),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.body,
        ),
      ),
    ],
  );
}

class _EarnButton extends StatelessWidget {
  const _EarnButton({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    return PressableScale(
      onTap: () {},
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? colors.primary : colors.textDisabled,
          borderRadius: context.radius.pillAll,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.xs,
          ),
          child: Text(
            context.l10n.challengeEarn.toUpperCase(),
            style: context.typography.button.copyWith(color: colors.onPrimary),
          ),
        ),
      ),
    );
  }
}

class _ChallengeArt extends StatelessWidget {
  const _ChallengeArt({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) => switch (challenge.kind) {
    ChallengeKind.donut => _DonutArt(challenge: challenge),
    ChallengeKind.coffee => ChallengeCoffeeArt(challenge: challenge),
  };
}

class _DonutArt extends StatelessWidget {
  const _DonutArt({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final image = AssetImageRef(challenge.imageAsset);
    final quarters = challenge.progressCurrent.clamp(0, 4);
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: quarters.toDouble()),
        duration: context.motion.scaleDuration(MotionTokens.artworkReveal),
        curve: MotionTokens.decelerate,
        builder: (context, value, _) => _DonutLayers(
          image: image,
          quarters: value.round().clamp(0, 4),
        ),
      ),
    );
  }
}

class _DonutLayers extends StatelessWidget {
  const _DonutLayers({required this.image, required this.quarters});

  final AssetImageRef image;
  final int quarters;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      ColorFiltered(
        colorFilter: _washedDonutFilter,
        child: AppImage(image: image, fit: BoxFit.contain),
      ),
      ClipPath(
        clipper: DonutQuarterClipper(quarters: quarters),
        child: AppImage(image: image, fit: BoxFit.contain),
      ),
    ],
  );
}
