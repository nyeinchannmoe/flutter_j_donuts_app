import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

/// Themed text field used by every form. Error and focus borders animate
/// through the framework's InputDecorator.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.controller,
    this.prefixText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.autofillHints,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    this.readOnly = false,
    this.showCursor,
    this.enableInteractiveSelection,
    this.onTap,
    this.decoration,
    this.style,
    super.key,
  });

  final TextEditingController? controller;
  final String label;
  final String? prefixText;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool? showCursor;
  final bool? enableInteractiveSelection;
  final VoidCallback? onTap;
  final InputDecoration? decoration;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    readOnly: readOnly,
    showCursor: showCursor,
    enableInteractiveSelection: enableInteractiveSelection,
    autofocus: autofocus,
    keyboardType: keyboardType,
    textCapitalization: textCapitalization,
    autocorrect: autocorrect,
    inputFormatters: inputFormatters,
    autofillHints: autofillHints,
    textInputAction: textInputAction,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    onTap: onTap,
    style: _withBaseline(style ?? context.typography.subtitle),
    decoration: decoration ?? _decoration(context),
  );

  InputDecoration _decoration(BuildContext context) {
    final colors = context.colors;
    final idle = _border(context, BorderSide.none);
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      errorText: errorText,
      filled: true,
      fillColor: colors.surface,
      contentPadding: EdgeInsets.all(context.spacing.lg),
      labelStyle: _withBaseline(
        context.typography.body,
      ).copyWith(color: colors.textSecondary),
      errorStyle: _withBaseline(
        context.typography.label,
      ).copyWith(color: colors.danger),
      border: idle,
      enabledBorder: idle,
      focusedBorder: _border(
        context,
        BorderSide(color: colors.primary, width: context.spacing.xxs),
      ),
      errorBorder: _border(context, BorderSide(color: colors.danger)),
    );
  }

  static TextStyle _withBaseline(TextStyle style) => style.copyWith(
    textBaseline: style.textBaseline ?? TextBaseline.alphabetic,
  );

  static OutlineInputBorder _border(BuildContext context, BorderSide side) =>
      OutlineInputBorder(borderRadius: context.radius.mdAll, borderSide: side);
}
