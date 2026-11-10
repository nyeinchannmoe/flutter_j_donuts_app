import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/widgets/buttons/pressable_scale.dart';

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
    this.usePrimaryDisabledFill = false,
    super.key,
  });

  final String label;

  /// Null disables the button.
  final FutureOr<void> Function()? onPressed;
  final bool isLoading;
  final Widget? trailing;

  final bool usePrimaryDisabledFill;

  static const Key progressKey = Key('app_button_progress');

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _busy = AnimationController(
    vsync: this,
    duration: MotionTokens.micro,
  );

  bool get _running => _busy.value > 0;

  bool get _isBusy => widget.isLoading || _running;

  Future<void> _handleTap() async {
    final onPressed = widget.onPressed;
    if (_isBusy || onPressed == null) return;
    _busy.value = 1;
    try {
      await onPressed();
    } finally {
      if (mounted) _busy.value = 0;
    }
  }

  @override
  void dispose() {
    _busy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _busy,
    builder: (context, _) {
      final enabled = widget.onPressed != null;
      final style = FilledButtonTheme.of(context).style!;
      final states = enabled ? <WidgetState>{} : {WidgetState.disabled};
      final fill = style.backgroundColor!.resolve(states);
      final background =
          !enabled && widget.usePrimaryDisabledFill && fill != null
          ? context.colors.primary.withValues(alpha: fill.a)
          : fill;
      return Semantics(
        button: true,
        enabled: enabled && !_isBusy,
        label: widget.label,
        onTap: enabled && !_isBusy ? _handleTap : null,
        excludeSemantics: true,
        child: PressableScale(
          onTap: enabled ? _handleTap : null,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: background,
              shape: style.shape!.resolve(states)!,
            ),
            child: _content(style, states),
          ),
        ),
      );
    },
  );

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
          busy: _isBusy,
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

  Widget _labelRow(BuildContext context) {
    final labelText = Text(
      label.toUpperCase(),
      style: labelStyle,
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
