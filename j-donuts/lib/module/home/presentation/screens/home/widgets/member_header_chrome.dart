import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';

/// Glow ring thickness relative to the avatar extent.
const double _avatarGlowSpreadFactor = 0.22;

/// Avatar grows slightly above the base icon token for the Home header.
const double _avatarScale = 1.15;

/// Resolved avatar diameter for the Home member header.
double memberHeaderAvatarExtent(BuildContext context) =>
    context.iconSizes.avatar * _avatarScale;

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({required this.member, required this.extent, super.key});

  final MemberProfile member;
  final double extent;

  @override
  Widget build(BuildContext context) {
    final glow = extent * _avatarGlowSpreadFactor;
    return Container(
      width: extent + glow,
      height: extent + glow,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.colors.avatarGlow,
            blurRadius: glow,
            spreadRadius: context.spacing.xs,
          ),
        ],
      ),
      child: ClipOval(
        child: SizedBox.square(
          dimension: extent,
          child: AppImage(
            image: ImageRef.fromSources(
              asset: member.photoAsset,
              url: member.photoUrl,
            ),
          ),
        ),
      ),
    );
  }
}

class MemberIdentity extends StatelessWidget {
  const MemberIdentity({required this.member, super.key});

  final MemberProfile member;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        member.name,
        style: context.typography.headline,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: context.spacing.xxs),
      Text(
        context.l10n.memberTier(member.tierName),
        style: context.typography.body.copyWith(
          color: context.colors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

class MemberPointsPill extends StatelessWidget {
  const MemberPointsPill({required this.member, super.key});

  final MemberProfile member;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.pillAll,
        boxShadow: context.shadows.card,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        child: Text(
          _pointsLabel(context),
          style: context.typography.caption.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _pointsLabel(BuildContext context) {
    final nextTier = member.nextTierName;
    if (nextTier == null) return context.l10n.topTierReached;
    return context.l10n.pointsToNextTier(
      MmkFormatter.amount(member.pointsToNextTier),
      nextTier,
    );
  }
}

class MemberNotificationBell extends StatelessWidget {
  const MemberNotificationBell({
    required this.count,
    required this.onPressed,
    super.key,
  });

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.notificationsCount(count),
    excludeSemantics: true,
    child: _BellChrome(count: count, onPressed: onPressed),
  );
}

class _BellChrome extends StatelessWidget {
  const _BellChrome({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final endPadding = count > 0 ? spacing.xs : spacing.sm;
    final shape = BorderRadiusDirectional.horizontal(
      start: Radius.circular(context.radius.pill),
    );
    return Material(
      color: colors.highlight,
      shape: RoundedRectangleBorder(
        borderRadius: shape.resolve(Directionality.of(context)),
        side: BorderSide(color: colors.onPrimary, width: spacing.xxs),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: spacing.sm,
            end: endPadding,
            top: spacing.xs,
            bottom: spacing.xs,
          ),
          child: _BellRow(count: count),
        ),
      ),
    );
  }
}

class _BellRow extends StatelessWidget {
  const _BellRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.notifications_none_rounded,
          size: context.iconSizes.md,
          color: context.colors.onPrimary,
        ),
        if (count > 0) ...[
          SizedBox(width: spacing.xs),
          _NotificationCountChip(count: count),
          SizedBox(width: spacing.xs),
        ],
      ],
    );
  }
}

class _NotificationCountChip extends StatelessWidget {
  const _NotificationCountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final extent = context.iconSizes.sm + context.spacing.xs;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: extent,
        child: Center(
          child: Text(
            count.toString(),
            style: context.typography.label.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
