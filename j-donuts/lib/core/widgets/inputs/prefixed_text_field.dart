import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonuts/core/widgets/inputs/filled_text_field.dart';

/// Phone-style field with a fixed dialling prefix beside the editable text.
class PrefixedTextField extends StatelessWidget {
  const PrefixedTextField({
    required this.label,
    required this.prefix,
    this.controller,
    this.errorText,
    this.hasError = false,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    super.key,
  });

  final String label;
  final String prefix;
  final TextEditingController? controller;
  final String? errorText;
  final bool hasError;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;

  @override
  Widget build(BuildContext context) => FilledTextField(
    label: label,
    prefix: prefix,
    controller: controller,
    errorText: errorText,
    hasError: hasError,
    readOnly: readOnly,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    autofillHints: autofillHints,
    inputFormatters: inputFormatters,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    onFocusChanged: onFocusChanged,
  );
}
