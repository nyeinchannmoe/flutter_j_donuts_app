import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

class BackTileButton extends StatelessWidget {
  const BackTileButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final extent =
        context.iconSizes.lg + context.spacing.xs + context.spacing.xxs;
    final target = context.spacing.xxxl;
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: target, height: target),
      onPressed: onPressed,
      icon: Container(
        width: extent,
        height: extent,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: context.radius.smAll,
        ),
        child: Icon(
          Icons.arrow_back,
          color: context.colors.textPrimary,
          size: context.iconSizes.md - context.spacing.xxs,
        ),
      ),
    );
  }
}
