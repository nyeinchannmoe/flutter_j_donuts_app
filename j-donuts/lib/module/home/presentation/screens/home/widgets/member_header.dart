import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/presentation/bloc/member_header/member_header_bloc.dart';

class MemberHeader extends StatelessWidget {
  const MemberHeader({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemberHeaderBloc, ViewState<MemberProfile>>(
        builder: (context, state) => ViewStateBuilder<MemberProfile>(
          state: state,
          skeleton: const _MemberHeaderSkeleton(),
          emptyMessage: context.l10n.emptyTitle,
          onRetry: () => context.read<MemberHeaderBloc>().add(
            const MemberHeaderRetried(),
          ),
          builder: (context, member) => _MemberHeaderContent(member: member),
        ),
      );
}

class _MemberHeaderContent extends StatelessWidget {
  const _MemberHeaderContent({required this.member});

  final MemberProfile member;

  @override
  Widget build(BuildContext context) {
    final avatar = context.iconSizes.avatar;
    return Row(
      children: [
        ClipOval(
          child: SizedBox.square(
            dimension: avatar,
            child: AppImage(
              image: ImageRef.fromSources(
                asset: member.photoAsset,
                url: member.photoUrl,
              ),
            ),
          ),
        ),
        SizedBox(width: context.spacing.md),
        Expanded(child: _MemberText(member: member)),
        _NotificationBell(count: member.notificationsCount),
      ],
    );
  }
}

class _MemberText extends StatelessWidget {
  const _MemberText({required this.member});

  final MemberProfile member;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nextTier = member.nextTierName;
    final progress = nextTier == null
        ? l10n.topTierReached
        : l10n.pointsToNextTier(
            MmkFormatter.amount(member.pointsToNextTier),
            nextTier,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(member.name, style: context.typography.title),
        Text(
          l10n.memberTier(member.tierName),
          style: context.typography.bodyStrong.copyWith(
            color: context.colors.tierColor(member.tierRank),
          ),
        ),
        Text(progress, style: context.typography.caption),
      ],
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.notificationsCount(count),
    excludeSemantics: true,
    child: Badge(
      isLabelVisible: count > 0,
      backgroundColor: context.colors.accent,
      label: Text(count.toString()),
      child: Icon(
        Icons.notifications_none_rounded,
        size: context.iconSizes.lg,
        color: context.colors.textPrimary,
      ),
    ),
  );
}

class _MemberHeaderSkeleton extends StatelessWidget {
  const _MemberHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Row(
      children: [
        SkeletonBlock(
          width: context.iconSizes.avatar,
          height: context.iconSizes.avatar,
          borderRadius: context.radius.pillAll,
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBlock(width: spacing.xxxl * 2, height: spacing.lg),
              SizedBox(height: spacing.sm),
              SkeletonBlock(height: spacing.md),
            ],
          ),
        ),
      ],
    );
  }
}
