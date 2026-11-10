import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

/// Themed text field used by every form. Error and focus borders animate
/// through the framework's InputDecorator.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    required this.label,
    this.prefixText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.autofillHints,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? prefixText;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    autofocus: autofocus,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    autofillHints: autofillHints,
    textInputAction: textInputAction,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    style: context.typography.subtitle,
    decoration: _decoration(context),
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
      labelStyle: context.typography.body.copyWith(color: colors.textSecondary),
      errorStyle: context.typography.label.copyWith(color: colors.danger),
      border: idle,
      enabledBorder: idle,
      focusedBorder: _border(
        context,
        BorderSide(color: colors.primary, width: context.spacing.xxs),
      ),
      errorBorder: _border(context, BorderSide(color: colors.danger)),
    );
  }

  static OutlineInputBorder _border(BuildContext context, BorderSide side) =>
      OutlineInputBorder(borderRadius: context.radius.mdAll, borderSide: side);
}
