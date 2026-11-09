import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';
import 'package:jdonuts/module/home/presentation/bloc/shops/shops_bloc.dart';

class NearbyShops extends StatelessWidget {
  const NearbyShops({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ShopsBloc, ViewState<List<Shop>>>(
        builder: (context, state) => ViewStateBuilder<List<Shop>>(
          state: state,
          skeleton: SkeletonBlock(height: context.iconSizes.illustration),
          emptyMessage: context.l10n.shopsEmpty,
          onRetry: () => context.read<ShopsBloc>().add(const ShopsRetried()),
          builder: (context, shops) => _ShopsContent(shops: shops),
        ),
      );
}

class _ShopsContent extends StatelessWidget {
  const _ShopsContent({required this.shops});

  final List<Shop> shops;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: context.spacing.md,
    children: [
      Semantics(
        header: true,
        child: Text(
          context.l10n.shopsTitle(shops.length),
          style: context.typography.title,
        ),
      ),
      for (final shop in shops) _ShopRow(shop: shop),
    ],
  );
}

class _ShopRow extends StatelessWidget {
  const _ShopRow({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final extent = context.iconSizes.xl;
    return Row(
      children: [
        ClipRRect(
          borderRadius: context.radius.mdAll,
          child: SizedBox.square(
            dimension: extent,
            child: AppImage(
              image: ImageRef.fromSources(
                asset: shop.imageAsset,
                url: shop.imageUrl,
              ),
            ),
          ),
        ),
        SizedBox(width: context.spacing.md),
        Expanded(child: _details(context)),
      ],
    );
  }

  Widget _details(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(shop.name, style: context.typography.bodyStrong),
      Text(
        shop.address,
        style: context.typography.caption.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    ],
  );
}
