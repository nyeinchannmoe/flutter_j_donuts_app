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
        builder: _buildStepper,
      );

  Widget _buildStepper(BuildContext context, ProductDetailState state) {
    final l10n = context.l10n;
    final bloc = context.read<ProductDetailBloc>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l10n.productQuantityDecrease,
          onPressed: state.canDecrement
              ? () => bloc.add(const ProductQuantityDecremented())
              : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        AnimatedQuantityText(
          value: state.quantity,
          style: context.typography.title,
        ),
        IconButton(
          tooltip: l10n.productQuantityIncrease,
          onPressed: state.canIncrement
              ? () => bloc.add(const ProductQuantityIncremented())
              : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
