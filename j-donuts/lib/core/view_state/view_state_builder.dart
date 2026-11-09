import 'package:flutter/material.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_group.dart';
import 'package:jdonuts/core/widgets/state_views/empty_state_view.dart';
import 'package:jdonuts/core/widgets/state_views/error_state_view.dart';

/// Renders each ViewState branch and cross-fades between them.
class ViewStateBuilder<T> extends StatelessWidget {
  const ViewStateBuilder({
    required this.state,
    required this.skeleton,
    required this.builder,
    required this.emptyMessage,
    this.onRetry,
    this.failureMessage,
    super.key,
  });

  final ViewState<T> state;
  final Widget skeleton;
  final Widget Function(BuildContext context, T value) builder;
  final String emptyMessage;
  final VoidCallback? onRetry;

  /// Optional override for specific failures, such as not-found.
  final String? Function(AppFailure failure)? failureMessage;

  @override
  Widget build(BuildContext context) {
    final profile = context.motion;
    return AnimatedSwitcher(
      duration: profile.scaleDuration(MotionTokens.standard),
      switchInCurve: MotionTokens.decelerate,
      switchOutCurve: MotionTokens.accelerate,
      child: KeyedSubtree(
        key: ValueKey<Type>(state.runtimeType),
        child: _branch(context),
      ),
    );
  }

  Widget _branch(BuildContext context) => switch (state) {
    ViewLoading<T>() => SkeletonGroup(child: skeleton),
    ViewData<T>(:final value) => builder(context, value),
    ViewEmpty<T>() => EmptyStateView(message: emptyMessage),
    ViewFailure<T>(:final failure) => ErrorStateView(
      failure: failure,
      onRetry: onRetry,
      message: failureMessage?.call(failure),
    ),
  };
}
