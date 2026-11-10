import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_policy.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';

/// Provides the resolved MotionProfile to the subtree.
///
/// Rebuilds dependents only when the profile actually changes: on a
/// reduce-motion toggle, a jank downgrade or a lifecycle change.
class MotionScope extends StatefulWidget {
  const MotionScope({required this.policy, required this.child, super.key});

  final MotionPolicy policy;
  final Widget child;

  static MotionProfile of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_MotionProfileScope>()
          ?.profile ??
      MotionProfile.full;

  @override
  State<MotionScope> createState() => _MotionScopeState();
}

class _MotionScopeState extends State<MotionScope> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) => widget.policy.updateAppActive(
        isActive: state == AppLifecycleState.resumed,
      ),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.policy,
    builder: (context, _) {
      final profile = widget.policy.resolve(
        disableAnimations: MediaQuery.disableAnimationsOf(context),
      );
      return _MotionProfileScope(profile: profile, child: widget.child);
    },
  );
}

class _MotionProfileScope extends InheritedWidget {
  const _MotionProfileScope({required this.profile, required super.child});

  final MotionProfile profile;

  @override
  bool updateShouldNotify(_MotionProfileScope oldWidget) =>
      oldWidget.profile != profile;
}

extension MotionContext on BuildContext {
  MotionProfile get motion => MotionScope.of(this);
}
