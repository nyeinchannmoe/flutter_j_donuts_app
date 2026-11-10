import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/primitives/pressable_scale.dart';

/// Primary pill button with press feedback, a loading morph and a
/// double-tap guard.
///
/// While [isLoading] is true, or while an async [onPressed] is still
/// running, further taps are ignored.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailing,
    super.key,
  });

  final String label;

  /// Null disables the button.
  final FutureOr<void> Function()? onPressed;
  final bool isLoading;
  final Widget? trailing;

  static const Key progressKey = Key('app_button_progress');

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _running = false;

  bool get _busy => widget.isLoading || _running;

  Future<void> _handleTap() async {
    final onPressed = widget.onPressed;
    if (_busy || onPressed == null) return;
    setState(() => _running = true);
    try {
      await onPressed();
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final style = FilledButtonTheme.of(context).style!;
    final states = enabled ? <WidgetState>{} : {WidgetState.disabled};
    return Semantics(
      button: true,
      enabled: enabled && !_busy,
      label: widget.label,
      excludeSemantics: true,
      child: PressableScale(
        onTap: enabled ? _handleTap : null,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: style.backgroundColor!.resolve(states),
            shape: style.shape!.resolve(states)!,
          ),
          child: _content(style, states),
        ),
      ),
    );
  }

  Widget _content(ButtonStyle style, Set<WidgetState> states) => ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: style.minimumSize!.resolve(states)!.height,
    ),
    child: Padding(
      padding: style.padding!.resolve(states)!,
      child: Center(
        heightFactor: 1,
        child: _ButtonContent(
          labelStyle: style.textStyle!.resolve(states)!,
          label: widget.label,
          busy: _busy,
          trailing: widget.trailing,
        ),
      ),
    ),
  );
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.busy,
    required this.labelStyle,
    this.trailing,
  });

  final String label;
  final bool busy;
  final TextStyle labelStyle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: context.motion.scaleDuration(MotionTokens.fast),
    child: busy
        ? SizedBox.square(
            key: AppButton.progressKey,
            dimension: context.iconSizes.md,
            child: CircularProgressIndicator(
              strokeWidth: context.spacing.xxs,
              color: labelStyle.color,
            ),
          )
        : _labelRow(context),
  );

  Widget _labelRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Flexible(
        child: Text(
          label.toUpperCase(),
          style: labelStyle,
          textAlign: TextAlign.center,
        ),
      ),
      if (trailing case final trailing?)
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerEnd,
            child: trailing,
          ),
        ),
    ],
  );
}
