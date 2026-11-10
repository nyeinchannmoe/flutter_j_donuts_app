import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/primitives/count_up_text.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_summary/rewards_summary_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/painters/glazed_points_ring_painter.dart';

/// Outer radius as a fraction of screen width.
const double rewardsRingRadiusFraction = 0.29;

/// Ring center from the left edge, as a width fraction.
const double rewardsRingCenterFromLeftFraction = 0.79;

/// Inner hole diameter as a fraction of the outer diameter.
const double _innerHoleFraction = 0.52;

/// Stroke width as a fraction of the outer diameter.
const double _strokeFraction = 0.17;

/// Glazed points ring (no left clipping — parent positions it).
class PointsSummary extends StatelessWidget {
  const PointsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final diameter = width * rewardsRingRadiusFraction * 2;
    return BlocBuilder<RewardsSummaryBloc, ViewState<MemberProfile>>(
      builder: (context, state) => ViewStateBuilder<MemberProfile>(
        state: state,
        skeleton: SizedBox.square(
          dimension: diameter,
          child: SkeletonBlock(
            width: diameter,
            height: diameter,
            borderRadius: context.radius.pillAll,
          ),
        ),
        emptyMessage: context.l10n.emptyTitle,
        onRetry: () => context.read<RewardsSummaryBloc>().add(
          const RewardsSummaryRetried(),
        ),
        builder: (context, member) =>
            _PointsRing(member: member, diameter: diameter),
      ),
    );
  }
}

class _PointsRing extends StatefulWidget {
  const _PointsRing({required this.member, required this.diameter});

  final MemberProfile member;
  final double diameter;

  @override
  State<_PointsRing> createState() => _PointsRingState();
}

class _PointsRingState extends State<_PointsRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.motion.scaleDuration(MotionTokens.countUp);
    if (_started || !TickerMode.valuesOf(context).enabled) return;
    _started = true;
    unawaited(
      _controller.animateTo(
        widget.member.progressTowardNextTier ?? 1,
        curve: MotionTokens.decelerate,
      ),
    );
  }

  @override
  void didUpdateWidget(_PointsRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(
      _controller.animateTo(
        widget.member.progressTowardNextTier ?? 1,
        curve: MotionTokens.decelerate,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = widget.member.progressTowardNextTier ?? 1;
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.diameter,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = progress <= 0 ? 0.0 : (_controller.value / progress);
            return CustomPaint(
              painter: GlazedPointsRingPainter(
                progress: _controller,
                trackColor: colors.surfaceMuted,
                glazeDeep: colors.accent,
                glazeMid: Color.lerp(colors.accent, colors.surface, 0.28)!,
                sprinkleColor: colors.surface,
                strokeWidth: widget.diameter * _strokeFraction,
                sprinkleReveal: t.clamp(0.0, 1.0),
                leaderGlow: t.clamp(0.0, 1.0),
                bandShine: t.clamp(0.0, 1.0),
              ),
              child: child,
            );
          },
          child: _RingLabel(
            points: widget.member.totalPoints,
            holeWidth: widget.diameter * _innerHoleFraction,
          ),
        ),
      ),
    );
  }
}

class _RingLabel extends StatelessWidget {
  const _RingLabel({required this.points, required this.holeWidth});

  final int points;
  final double holeWidth;

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.accent;
    return Center(
      child: SizedBox(
        width: holeWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TotalPointsCaption(color: accent),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: CountUpText(
                value: points,
                format: MmkFormatter.amount,
                style: context.typography.title.copyWith(color: accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalPointsCaption extends StatelessWidget {
  const _TotalPointsCaption({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    context.l10n.rewardsTotalPoints,
    textAlign: TextAlign.center,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: context.typography.caption.copyWith(color: color),
  );
}
