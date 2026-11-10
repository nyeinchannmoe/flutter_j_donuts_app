import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/animated_quantity_text.dart';
import 'package:jdonuts/module/product/presentation/bloc/product_detail/product_detail_bloc.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProductDetailBloc, ProductDetailState>(
        buildWhen: (previous, current) => previous.quantity != current.quantity,
        builder: (context, state) => _StepperShell(state: state),
      );
}

class _StepperShell extends StatelessWidget {
  const _StepperShell({required this.state});

  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.pillAll,
        border: Border.all(color: context.colors.border),
        boxShadow: context.shadows.card,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        child: _StepperControls(state: state),
      ),
    );
  }
}

class _StepperControls extends StatelessWidget {
  const _StepperControls({required this.state});

  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProductDetailBloc>();
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          tooltip: l10n.productQuantityDecrease,
          onPressed: state.canDecrement
              ? () => bloc.add(const ProductQuantityDecremented())
              : null,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.lg),
          child: AnimatedQuantityText(
            value: state.quantity,
            style: context.typography.title,
          ),
        ),
        _StepButton(
          icon: Icons.add,
          tooltip: l10n.productQuantityIncrease,
          onPressed: state.canIncrement
              ? () => bloc.add(const ProductQuantityIncremented())
              : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: enabled ? colors.primary : colors.border,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox.square(
              dimension: context.iconSizes.lg,
              child: Icon(
                icon,
                size: context.iconSizes.sm,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
