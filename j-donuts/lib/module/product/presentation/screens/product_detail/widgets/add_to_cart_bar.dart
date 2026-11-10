import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/module/product/presentation/bloc/product_detail/product_detail_bloc.dart';

/// Bottom bar with the live total and the add-to-cart button.
class AddToCartBar extends StatelessWidget {
  const AddToCartBar({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        context.layout.horizontalGutter,
        context.spacing.sm,
        context.layout.horizontalGutter,
        context.spacing.lg,
      ),
      child: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        buildWhen: (previous, current) =>
            previous.totalMmk != current.totalMmk ||
            previous.cartStatus != current.cartStatus,
        builder: (context, state) => AppButton(
          label: context.l10n.productAddToCart,
          isLoading: state.cartStatus == CartStatus.adding,
          onPressed: () => context.read<ProductDetailBloc>().add(
            const ProductAddToCartPressed(),
          ),
          trailing: Text(
            context.l10n.priceMmk(MmkFormatter.amount(state.totalMmk)),
            style: context.typography.button.copyWith(
              color: context.colors.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
