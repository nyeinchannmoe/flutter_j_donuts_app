import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/shake_on_trigger.dart';
import 'package:jdonuts/core/widgets/inputs/segmented_code_cells.dart';

/// Fixed-length digit entry driven by one hidden field and visible cells.
class SegmentedCodeField extends StatefulWidget {
  const SegmentedCodeField({
    required this.length,
    required this.value,
    required this.onChanged,
    required this.onCompleted,
    required this.hasError,
    required this.enabled,
    required this.isLoading,
    required this.shakeEpoch,
    required this.semanticsLabel,
    this.autofocus = true,
    super.key,
  });

  final int length;
  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;
  final bool hasError;
  final bool enabled;
  final bool isLoading;
  final int shakeEpoch;
  final String semanticsLabel;
  final bool autofocus;

  @override
  State<SegmentedCodeField> createState() => _SegmentedCodeFieldState();
}

class _SegmentedCodeFieldState extends State<SegmentedCodeField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  var _lastCompleted = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value)
      ..addListener(_emitChanges);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(SegmentedCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
    if (!widget.enabled && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_emitChanges)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _emitChanges() {
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > widget.length
        ? digits.substring(0, widget.length)
        : digits;
    if (clipped != _controller.text) {
      _controller.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
      return;
    }
    widget.onChanged(clipped);
    if (clipped.length == widget.length && clipped != _lastCompleted) {
      _lastCompleted = clipped;
      widget.onCompleted(clipped);
    }
    if (clipped.length < widget.length) {
      _lastCompleted = '';
    }
  }

  void _focusAt(int index) {
    if (!widget.enabled) return;
    _focusNode.requestFocus();
    final offset = index.clamp(0, _controller.text.length);
    _controller.selection = TextSelection.collapsed(offset: offset);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _HiddenFieldStack(
        semanticsLabel: widget.semanticsLabel,
        shakeEpoch: widget.shakeEpoch,
        cells: ListenableBuilder(
          listenable: _focusNode,
          builder: (context, _) => SegmentedCodeCells(
            length: widget.length,
            value: widget.value,
            hasError: widget.hasError,
            focused: _focusNode.hasFocus,
            onCellTap: _focusAt,
          ),
        ),
        field: _hiddenField(context),
      ),
      if (widget.isLoading) const _LoadingMark(),
    ],
  );

  Widget _hiddenField(BuildContext context) {
    final clear = context.colors.surface.withValues(alpha: 0);
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus && widget.enabled,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      showCursor: false,
      style: context.typography.body.copyWith(color: clear),
      cursorColor: clear,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.length),
      ],
      decoration: const InputDecoration(
        border: InputBorder.none,
        counterText: '',
        isCollapsed: true,
      ),
    );
  }
}

class _HiddenFieldStack extends StatelessWidget {
  const _HiddenFieldStack({
    required this.semanticsLabel,
    required this.shakeEpoch,
    required this.cells,
    required this.field,
  });

  final String semanticsLabel;
  final int shakeEpoch;
  final Widget cells;
  final Widget field;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticsLabel,
    textField: true,
    child: ShakeOnTrigger(
      trigger: shakeEpoch,
      child: Material(
        color: context.colors.surface.withValues(alpha: 0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            cells,
            Positioned.fill(child: field),
          ],
        ),
      ),
    ),
  );
}

class _LoadingMark extends StatelessWidget {
  const _LoadingMark();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(height: context.spacing.md),
      Center(
        child: SizedBox.square(
          dimension: context.iconSizes.sm,
          child: CircularProgressIndicator(
            strokeWidth: context.spacing.xxs,
            color: context.colors.accent,
          ),
        ),
      ),
    ],
  );
}
