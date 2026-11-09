import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

/// Placeholder shape painted in the shimmer base color.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({this.width, this.height, this.borderRadius, super.key});

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.shimmerBase,
      borderRadius: borderRadius ?? context.radius.mdAll,
    ),
    child: SizedBox(width: width, height: height),
  );
}
