import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/primitives/pressable_scale.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';

/// Shop image width-to-height ratio from the Explore Now design.
const double _shopImageAspectRatio = 1.45;

/// White shop card used in the Explore Now horizontal carousel.
class ShopCard extends StatelessWidget {
  const ShopCard({
    required this.shop,
    required this.width,
    required this.onOrderOnline,
    super.key,
  });

  final Shop shop;
  final double width;
  final VoidCallback onOrderOnline;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.xlAll,
        boxShadow: context.shadows.card,
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.md),
        child: _ShopCardBody(shop: shop, onOrderOnline: onOrderOnline),
      ),
    ),
  );
}

class _ShopCardBody extends StatelessWidget {
  const _ShopCardBody({required this.shop, required this.onOrderOnline});

  final Shop shop;
  final VoidCallback onOrderOnline;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShopImage(shop: shop),
        SizedBox(height: spacing.md),
        _ShopLabels(shop: shop),
        SizedBox(height: spacing.sm),
        _OrderOnlineAction(onPressed: onOrderOnline),
      ],
    );
  }
}

class _ShopLabels extends StatelessWidget {
  const _ShopLabels({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        shop.name,
        style: context.typography.subtitle.copyWith(
          fontWeight: FontWeight.w700,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: context.spacing.xs),
      Text(
        shop.address,
        style: context.typography.caption.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    ],
  );
}

class _OrderOnlineAction extends StatelessWidget {
  const _OrderOnlineAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: PressableScale(
      onTap: onPressed,
      child: Text(
        context.l10n.shopsOrderOnline,
        style: context.typography.bodyStrong.copyWith(
          color: context.colors.accent,
        ),
      ),
    ),
  );
}

class _ShopImage extends StatelessWidget {
  const _ShopImage({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: context.radius.lgAll,
    child: AspectRatio(
      aspectRatio: _shopImageAspectRatio,
      child: AppImage(
        image: ImageRef.fromSources(
          asset: shop.imageAsset,
          url: shop.imageUrl,
        ),
        semanticLabel: shop.name,
      ),
    ),
  );
}
