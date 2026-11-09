import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/theme/tokens/app_spacing.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/presentation/bloc/member_header/member_header_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/member_header_chrome.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/member_header_decor.dart';

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
    final avatar = memberHeaderAvatarExtent(context);
    final spacing = context.spacing;
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
            _MemberHeaderRow(member: member, avatarExtent: avatar),
            SizedBox(height: spacing.md),
            MemberPointsPill(member: member),
          ],
        ),
      ],
    );
  }
}

class _MemberHeaderRow extends StatelessWidget {
  const _MemberHeaderRow({required this.member, required this.avatarExtent});

  final MemberProfile member;
  final double avatarExtent;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MemberAvatar(member: member, extent: avatarExtent),
      SizedBox(width: context.spacing.md),
      Expanded(child: MemberIdentity(member: member)),
      MemberNotificationBell(count: member.notificationsCount),
    ],
  );
}

class _MemberHeaderSkeleton extends StatelessWidget {
  const _MemberHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final avatar = memberHeaderAvatarExtent(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonTopRow(spacing: spacing, avatar: avatar),
        SizedBox(height: spacing.md),
        SkeletonBlock(
          width: spacing.xxxl * 3,
          height: spacing.xl,
          borderRadius: context.radius.pillAll,
        ),
      ],
    );
  }
}

class _SkeletonTopRow extends StatelessWidget {
  const _SkeletonTopRow({required this.spacing, required this.avatar});

  final AppSpacing spacing;
  final double avatar;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SkeletonBlock(
        width: avatar,
        height: avatar,
        borderRadius: context.radius.pillAll,
      ),
      SizedBox(width: spacing.md),
      Expanded(child: _MemberTextSkeleton(spacing: spacing)),
      SkeletonBlock(
        width: spacing.xxxl,
        height: spacing.xl,
        borderRadius: context.radius.pillAll,
      ),
    ],
  );
}

class _MemberTextSkeleton extends StatelessWidget {
  const _MemberTextSkeleton({required this.spacing});

  final AppSpacing spacing;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SkeletonBlock(width: spacing.xxxl * 2, height: spacing.lg),
      SizedBox(height: spacing.sm),
      SkeletonBlock(width: spacing.xxxl, height: spacing.md),
    ],
  );
}
