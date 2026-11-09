import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/painters/arc_sweep_painter.dart';
import 'package:jdonuts/core/motion/primitives/count_up_text.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_summary/rewards_summary_bloc.dart';

/// Ring diameter as a fraction of the screen width.
const double _ringWidthFraction = 0.55;

/// Ring stroke as a fraction of its diameter.
const double _ringStrokeFraction = 0.08;

class PointsSummary extends StatelessWidget {
  const PointsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final extent = context.layout.size.width * _ringWidthFraction;
    return BlocBuilder<RewardsSummaryBloc, ViewState<MemberProfile>>(
      builder: (context, state) => ViewStateBuilder<MemberProfile>(
        state: state,
        skeleton: Center(
          child: SkeletonBlock(
            width: extent,
            height: extent,
            borderRadius: context.radius.pillAll,
          ),
        ),
        emptyMessage: context.l10n.emptyTitle,
        onRetry: () => context.read<RewardsSummaryBloc>().add(
          const RewardsSummaryRetried(),
        ),
        builder: (context, member) => Center(
          child: _PointsRing(member: member, extent: extent),
        ),
      ),
    );
  }
}

class _PointsRing extends StatefulWidget {
  const _PointsRing({required this.member, required this.extent});

  final MemberProfile member;
  final double extent;

  @override
  State<_PointsRing> createState() => _PointsRingState();
}

class _PointsRingState extends State<_PointsRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
  );

  double get _fraction {
    final member = widget.member;
    final goal = member.totalPoints + member.pointsToNextTier;
    return member.hasNextTier && goal > 0 ? member.totalPoints / goal : 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.motion.scaleDuration(MotionTokens.countUp);
    _sweep();
  }

  @override
  void didUpdateWidget(_PointsRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sweep();
  }

  void _sweep() => unawaited(
    _controller.animateTo(_fraction, curve: MotionTokens.decelerate),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.extent,
        child: CustomPaint(
          painter: ArcSweepPainter(
            progress: _controller,
            trackColor: colors.surfaceMuted,
            gradientColors: [colors.primary, colors.accent],
            strokeWidth: widget.extent * _ringStrokeFraction,
          ),
          child: _RingLabel(points: widget.member.totalPoints),
        ),
      ),
    );
  }
}

class _RingLabel extends StatelessWidget {
  const _RingLabel({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CountUpText(
          value: points,
          format: MmkFormatter.amount,
          style: context.typography.metric,
        ),
        Text(
          context.l10n.rewardsTotalPoints,
          style: context.typography.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
