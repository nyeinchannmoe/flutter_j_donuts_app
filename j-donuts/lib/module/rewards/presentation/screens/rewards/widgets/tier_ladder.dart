import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/primitives/fade_slide_in.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/rewards/domain/entities/tier.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_summary/rewards_summary_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/tier_ladder/tier_ladder_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/rewards_badge_assets.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/painters/tier_progress_line_painter.dart';

/// Track stroke width in logical pixels.
const double _connectorStroke = 3;

/// Gap from each shield edge to the track, as a width fraction.
const double _connectorEndGapFraction = 0.01;

/// Visible track length between end gaps.
const double _connectorTrackLength = 20;

/// Space between shield column and tier captions.
const double _badgeToTextGap = 8;

/// Vertical Silver → Gold → Platinum ladder with gapped segment tracks.
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
        builder: (context, tiers) {
          final visible = _visibleTiers(tiers, member);
          if (visible.isEmpty) {
            return Text(
              context.l10n.emptyTitle,
              style: context.typography.body.copyWith(
                color: context.colors.textSecondary,
              ),
            );
          }
          return _TierLadderBody(tiers: visible, member: member);
        },
      ),
    );
  }

  List<Tier> _visibleTiers(List<Tier> tiers, MemberProfile? member) {
    final rank = member?.tierRank ?? 0;
    return [
      for (final tier in tiers)
        if (tier.rank >= rank) tier,
    ];
  }
}

class _TierLadderBody extends StatelessWidget {
  const _TierLadderBody({required this.tiers, required this.member});

  final List<Tier> tiers;
  final MemberProfile? member;

  @override
  Widget build(BuildContext context) {
    final badge = context.iconSizes.tierBadge;
    final endGap = MediaQuery.sizeOf(context).width * _connectorEndGapFraction;
    final progress = member?.progressTowardNextTier ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiers.length; i++) ...[
          FadeSlideIn(
            distance: MotionTokens.tierEntranceTravel,
            child: _TierRow(
              tier: tiers[i],
              member: member,
              columnWidth: badge,
            ),
          ),
          if (i < tiers.length - 1)
            _SegmentConnector(
              fill: i == 0 ? progress : 0,
              badgeSize: badge,
              endGap: endGap,
            ),
        ],
      ],
    );
  }
}

class _SegmentConnector extends StatefulWidget {
  const _SegmentConnector({
    required this.fill,
    required this.badgeSize,
    required this.endGap,
  });

  final double fill;
  final double badgeSize;
  final double endGap;

  @override
  State<_SegmentConnector> createState() => _SegmentConnectorState();
}

class _SegmentConnectorState extends State<_SegmentConnector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.motion.scaleDuration(
      MotionTokens.tierLineFill,
    );
    if (_started || !TickerMode.valuesOf(context).enabled) return;
    _started = true;
    unawaited(
      _controller.animateTo(widget.fill, curve: MotionTokens.decelerate),
    );
  }

  @override
  void didUpdateWidget(_SegmentConnector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fill != widget.fill) {
      unawaited(
        _controller.animateTo(widget.fill, curve: MotionTokens.decelerate),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final left = widget.badgeSize * 0.5 - _connectorStroke * 0.5;
    return SizedBox(
      height: widget.endGap * 2 + _connectorTrackLength,
      width: widget.badgeSize,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: widget.endGap),
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(left: left),
            child: SizedBox(
              width: _connectorStroke,
              height: _connectorTrackLength,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: TierProgressLinePainter(
                    progress: _controller,
                    trackColor: colors.border,
                    fillColor: colors.textSecondary,
                    strokeWidth: _connectorStroke,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.tier,
    required this.member,
    required this.columnWidth,
  });

  final Tier tier;
  final MemberProfile? member;
  final double columnWidth;

  @override
  Widget build(BuildContext context) {
    final isCurrent = member?.tierRank == tier.rank;
    final size = isCurrent
        ? context.iconSizes.tierBadge
        : context.iconSizes.tierBadgeMuted;
    final asset = RewardsBadgeAssets.forTierId(tier.id);
    return Row(
      children: [
        SizedBox(
          width: columnWidth,
          height: context.iconSizes.tierBadge,
          child: Center(
            child: SizedBox.square(
              dimension: size,
              child: asset == null
                  ? const SizedBox.shrink()
                  : AppImage(
                      image: AssetImageRef(asset),
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
        const SizedBox(width: _badgeToTextGap),
        Expanded(child: _texts(context, isCurrent)),
      ],
    );
  }

  Widget _texts(BuildContext context, bool isCurrent) {
    final caption = _caption(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tier.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isCurrent
              ? context.typography.subtitle
              : context.typography.bodyStrong,
        ),
        if (caption != null)
          Text(
            caption,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: context.typography.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
      ],
    );
  }

  String? _caption(BuildContext context) {
    final current = member;
    if (current == null) return null;
    final l10n = context.l10n;
    final rank = current.tierRank;
    if (tier.rank == rank) return l10n.tierCurrent;
    if (tier.rank == rank + 1) {
      return l10n.tierRemaining(
        MmkFormatter.amount(current.pointsToNextTier),
        tier.name,
      );
    }
    return l10n.tierFuture;
  }
}
