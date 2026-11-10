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
    final colors = context.colors;
    return Semantics(
      button: true,
      enabled: enabled && !_busy,
      label: widget.label,
      excludeSemantics: true,
      child: PressableScale(
        onTap: enabled ? _handleTap : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled ? colors.primary : colors.border,
            borderRadius: context.radius.pillAll,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.xl,
              vertical: context.spacing.lg,
            ),
            child: _ButtonContent(
              label: widget.label,
              busy: _busy,
              trailing: widget.trailing,
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.busy,
    this.trailing,
  });

  final String label;
  final bool busy;
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
              color: context.colors.onPrimary,
            ),
          )
        : _labelRow(context),
  );

  Widget _labelRow(BuildContext context) {
    final labelText = Text(
      label.toUpperCase(),
      style: context.typography.button.copyWith(
        color: context.colors.onPrimary,
      ),
      textAlign: TextAlign.center,
    );
    final trailingWidget = trailing;
    if (trailingWidget == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Flexible(child: labelText)],
      );
    }
    return Row(
      children: [
        Expanded(child: labelText),
        _ButtonDivider(height: context.iconSizes.md),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: trailingWidget,
          ),
        ),
      ],
    );
  }
}

class _ButtonDivider extends StatelessWidget {
  const _ButtonDivider({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: VerticalDivider(
      width: context.spacing.lg,
      thickness: context.spacing.xxs / 2,
      color: context.colors.onPrimary,
    ),
  );
}
