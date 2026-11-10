import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/extensions/failure_localization.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';
import 'package:jdonuts/module/product/presentation/bloc/product_detail/product_detail_bloc.dart';
import 'package:jdonuts/module/product/presentation/screens/product_detail/widgets/add_to_cart_bar.dart';
import 'package:jdonuts/module/product/presentation/screens/product_detail/widgets/product_detail_body.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context) =>
      BlocListener<ProductDetailBloc, ProductDetailState>(
        listenWhen: (previous, current) =>
            previous.cartStatus != current.cartStatus &&
            (current.cartStatus == CartStatus.added ||
                current.cartStatus == CartStatus.failed),
        listener: _showCartResult,
        child: Scaffold(
          backgroundColor: context.colors.surface,
          appBar: AppBar(
            backgroundColor: context.colors.surface,
            leading: BackButton(color: context.colors.textPrimary),
          ),
          body: _ProductBody(productId: productId),
        ),
      );

  static void _showCartResult(BuildContext context, ProductDetailState state) {
    final l10n = context.l10n;
    final message = state.cartStatus == CartStatus.added
        ? l10n.productAddedToCart(state.lastAddedQuantity)
        : (state.cartFailure?.localizedMessage(l10n) ?? l10n.failureUnexpected);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProductBody extends StatelessWidget {
  const _ProductBody({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProductDetailBloc, ProductDetailState>(
        buildWhen: (previous, current) => previous.product != current.product,
        builder: (context, state) => ViewStateBuilder<Product>(
          state: state.product,
          skeleton: const _ProductSkeleton(),
          emptyMessage: context.l10n.productNotFound,
          onRetry: () => context.read<ProductDetailBloc>().add(
            ProductDetailStarted(productId),
          ),
          failureMessage: (failure) =>
              failure is NotFoundFailure ? context.l10n.productNotFound : null,
          builder: (context, product) => Column(
            children: [
              Expanded(child: ProductDetailBody(product: product)),
              const AddToCartBar(),
            ],
          ),
        ),
      );
}

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.all(layout.horizontalGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.md,
        children: [
          Center(
            child: SkeletonBlock(
              width: layout.heroImageExtent,
              height: layout.heroImageExtent,
              borderRadius: context.radius.pillAll,
            ),
          ),
          SkeletonBlock(height: spacing.xl),
          SkeletonBlock(height: spacing.lg),
        ],
      ),
    );
  }
}
