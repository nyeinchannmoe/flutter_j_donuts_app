import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';

class SegmentedCodeCells extends StatelessWidget {
  const SegmentedCodeCells({
    required this.length,
    required this.value,
    required this.hasError,
    required this.focused,
    required this.onCellTap,
    super.key,
  });

  final int length;
  final String value;
  final bool hasError;
  final bool focused;
  final ValueChanged<int> onCellTap;

  @override
  Widget build(BuildContext context) {
    final gap = context.spacing.sm;
    return LayoutBuilder(
      builder: (context, constraints) => _row(
        gap: gap,
        extent: (constraints.maxWidth - gap * (length - 1)) / length,
      ),
    );
  }

  Widget _row({required double gap, required double extent}) => Row(
    children: [
      for (var index = 0; index < length; index++) ...[
        if (index > 0) SizedBox(width: gap),
        SizedBox.square(
          dimension: extent,
          child: _SegmentedCodeCell(
            digit: index < value.length ? value[index] : null,
            active: focused &&
                index == value.length.clamp(0, length - 1) &&
                value.length < length,
            filledActive:
                focused && value.length == length && index == length - 1,
            hasError: hasError,
            onTap: () => onCellTap(index),
          ),
        ),
      ],
    ],
  );
}

class _SegmentedCodeCell extends StatelessWidget {
  const _SegmentedCodeCell({
    required this.digit,
    required this.active,
    required this.filledActive,
    required this.hasError,
    required this.onTap,
  });

  final String? digit;
  final bool active;
  final bool filledActive;
  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: context.radius.mdAll,
        child: AnimatedContainer(
          duration: context.motion.scaleDuration(MotionTokens.fast),
          curve: MotionTokens.standardCurve,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: context.radius.mdAll,
            border: Border.all(
              color: _borderColor(colors),
              width: context.spacing.xxs,
            ),
          ),
          child: Text(
            digit ?? '',
            style: context.typography.body.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Color _borderColor(AppColors colors) {
    if (hasError) return colors.danger;
    if (active || filledActive) return colors.primary;
    return colors.surface.withValues(alpha: 0);
  }
}
