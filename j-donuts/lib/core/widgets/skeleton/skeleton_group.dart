import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_scope.dart';

/// Applies one shimmer gradient pass to all SkeletonBlocks inside it.
class SkeletonGroup extends StatefulWidget {
  const SkeletonGroup({required this.child, super.key});

  final Widget child;

  @override
  State<SkeletonGroup> createState() => _SkeletonGroupState();
}

class _SkeletonGroupState extends State<SkeletonGroup> {
  static const double _bandWidth = 0.35;

  SkeletonShimmer? _shimmer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shimmer = SkeletonScope.maybeOf(context);
    if (shimmer == _shimmer) return;
    _shimmer?.release();
    _shimmer = shimmer?..acquire();
  }

  @override
  void dispose() {
    _shimmer?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _shimmer?.animation;
    final colors = context.colors;
    final content = ExcludeSemantics(child: widget.child);
    if (animation == null) return content;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              colors.shimmerBase,
              colors.shimmerHighlight,
              colors.shimmerBase,
            ],
            stops: _stopsFor(animation.value),
          ).createShader(bounds),
          child: child,
        ),
        child: content,
      ),
    );
  }

  static List<double> _stopsFor(double t) {
    final center = -_bandWidth + t * (1 + 2 * _bandWidth);
    return [center - _bandWidth, center, center + _bandWidth];
  }
}
