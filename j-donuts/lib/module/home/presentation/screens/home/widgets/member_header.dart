import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/presentation/bloc/member_header/member_header_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/member_header_chrome.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/member_header_decor.dart';

class MemberHeader extends StatelessWidget {
  const MemberHeader({required this.onNotificationsPressed, super.key});

  final VoidCallback onNotificationsPressed;

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
          builder: (context, member) => _MemberHeaderContent(
            member: member,
            onNotificationsPressed: onNotificationsPressed,
          ),
        ),
      );
}

class _MemberHeaderContent extends StatelessWidget {
  const _MemberHeaderContent({
    required this.member,
    required this.onNotificationsPressed,
  });

  final MemberProfile member;
  final VoidCallback onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    final avatar = memberHeaderAvatarExtent(context);
    final spacing = context.spacing;
    final gutter = context.layout.horizontalGutter;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bound the decor stack to the header content size; a bare Stack of
        // only Positioned children cannot size itself inside a ListView.
        Positioned.fill(
          child: MemberHeaderDecor(avatarExtent: avatar),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MemberHeaderRow(
              member: member,
              avatarExtent: avatar,
              onNotificationsPressed: onNotificationsPressed,
            ),
            SizedBox(height: spacing.md),
            Padding(
              padding: EdgeInsetsDirectional.only(start: gutter),
              child: MemberPointsPill(member: member),
            ),
          ],
        ),
      ],
    );
  }
}

class _MemberHeaderRow extends StatelessWidget {
  const _MemberHeaderRow({
    required this.member,
    required this.avatarExtent,
    required this.onNotificationsPressed,
  });

  final MemberProfile member;
  final double avatarExtent;
  final VoidCallback onNotificationsPressed;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: context.layout.horizontalGutter),
      MemberAvatar(member: member, extent: avatarExtent),
      SizedBox(width: context.spacing.md),
      Expanded(child: MemberIdentity(member: member)),
      MemberNotificationBell(
        count: member.notificationsCount,
        onPressed: onNotificationsPressed,
      ),
    ],
  );
}

/// Per-feature placeholders: avatar, name, tier, bell and points pill.
class _MemberHeaderSkeleton extends StatelessWidget {
  const _MemberHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final avatar = memberHeaderAvatarExtent(context);
    final gutter = context.layout.horizontalGutter;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemberTopSkeleton(avatar: avatar),
        SizedBox(height: spacing.md),
        Padding(
          padding: EdgeInsetsDirectional.only(start: gutter),
          child: SkeletonBlock(
            width: spacing.xxxl * 3,
            height: spacing.xl,
            borderRadius: context.radius.pillAll,
          ),
        ),
      ],
    );
  }
}

class _MemberTopSkeleton extends StatelessWidget {
  const _MemberTopSkeleton({required this.avatar});

  final double avatar;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: context.layout.horizontalGutter),
        SkeletonBlock(
          width: avatar,
          height: avatar,
          borderRadius: context.radius.pillAll,
        ),
        SizedBox(width: spacing.md),
        const Expanded(child: _MemberIdentitySkeleton()),
        SkeletonBlock(
          width: spacing.xxxl,
          height: spacing.xl,
          borderRadius: BorderRadiusDirectional.horizontal(
            start: Radius.circular(context.radius.pill),
          ).resolve(Directionality.of(context)),
        ),
      ],
    );
  }
}

class _MemberIdentitySkeleton extends StatelessWidget {
  const _MemberIdentitySkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(width: spacing.xxxl * 2, height: spacing.lg),
        SizedBox(height: spacing.sm),
        SkeletonBlock(width: spacing.xxxl, height: spacing.md),
      ],
    );
  }
}
