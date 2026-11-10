import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/widgets/inputs/app_text_field.dart';

/// White rounded field with a muted placeholder, animated focus and error
/// borders, and no floating label.
class FilledTextField extends StatefulWidget {
  const FilledTextField({
    required this.label,
    this.prefix,
    this.controller,
    this.focusNode,
    this.errorText,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.autocorrect = true,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    super.key,
  });

  final String label;
  final String? prefix;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<FilledTextField> createState() => _FilledTextFieldState();
}

class _FilledTextFieldState extends State<FilledTextField> {
  FocusNode? _ownedFocus;

  FocusNode get _focus => widget.focusNode ?? _ownedFocus!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _ownedFocus = FocusNode();
    }
    _focus.addListener(_notifyFocus);
  }

  @override
  void didUpdateWidget(covariant FilledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == widget.focusNode) return;
    (oldWidget.focusNode ?? _ownedFocus)?.removeListener(_notifyFocus);
    if (widget.focusNode == null) {
      _ownedFocus ??= FocusNode();
    } else if (oldWidget.focusNode == null) {
      _ownedFocus?.dispose();
      _ownedFocus = null;
    }
    _focus.addListener(_notifyFocus);
  }

  void _notifyFocus() => widget.onFocusChanged?.call(_focus.hasFocus);

  @override
  void dispose() {
    _focus.removeListener(_notifyFocus);
    _ownedFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.errorText;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : context.motion.scaleDuration(MotionTokens.fast);
    final message = error == null
        ? const SizedBox.shrink()
        : _error(context, error);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenableBuilder(
          listenable: _focus,
          builder: (context, _) =>
              _frame(context, duration, error != null, widget.readOnly),
        ),
        if (reduceMotion)
          message
        else
          AnimatedSize(
            duration: duration,
            curve: MotionTokens.standardCurve,
            alignment: Alignment.topLeft,
            child: message,
          ),
      ],
    );
  }

  Widget _error(BuildContext context, String error) => Padding(
    padding: EdgeInsets.only(top: context.spacing.xs),
    child: Semantics(
      liveRegion: true,
      child: Text(
        error,
        style: context.typography.caption.copyWith(
          color: context.colors.danger,
        ),
      ),
    ),
  );

  Widget _frame(
    BuildContext context,
    Duration duration,
    bool invalid,
    bool busy,
  ) => AnimatedContainer(
    duration: duration,
    curve: MotionTokens.standardCurve,
    constraints: BoxConstraints(
      minHeight: context.spacing.xxxl + context.spacing.lg + context.spacing.xs,
    ),
    padding: EdgeInsets.symmetric(
      horizontal: context.spacing.lg + context.spacing.xxs,
    ),
    decoration: _decoration(context, invalid),
    child: widget.prefix == null
        ? _input(context, busy)
        : Row(
            children: [
              Text(
                widget.prefix!,
                style: _style(context, context.colors.textDisabled),
              ),
              SizedBox(width: context.spacing.xl),
              Expanded(child: _input(context, busy)),
            ],
          ),
  );

  BoxDecoration _decoration(BuildContext context, bool invalid) {
    final colors = context.colors;
    return BoxDecoration(
      color: colors.surface,
      borderRadius: context.radius.smAll,
      border: Border.all(
        color: invalid
            ? colors.danger
            : _focus.hasFocus
            ? colors.primary
            : colors.surface.withValues(alpha: 0),
      ),
    );
  }

  TextStyle _style(BuildContext context, Color color) => context.typography.body
      .copyWith(color: color, textBaseline: TextBaseline.alphabetic);

  Widget _input(BuildContext context, bool busy) => Semantics(
    label: widget.label,
    child: AppTextField(
      label: widget.label,
      controller: widget.controller,
      focusNode: _focus,
      readOnly: busy,
      autofocus: widget.autofocus,
      style: _style(context, context.colors.textPrimary),
      decoration: _inputDecoration(context),
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    ),
  );

  InputDecoration _inputDecoration(BuildContext context) => InputDecoration(
    isCollapsed: true,
    filled: false,
    hintText: widget.prefix == null ? widget.label : null,
    hintStyle: _style(context, context.colors.textDisabled),
    contentPadding: EdgeInsets.symmetric(
      vertical: context.spacing.lg + context.spacing.xxs,
    ),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
  );
}
