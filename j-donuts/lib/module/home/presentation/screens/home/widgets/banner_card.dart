import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/module/home/domain/entities/home_banner.dart';

/// Leaves a peek of the next banner when more than one exists.
const double bannerViewportFraction = 0.86;

/// Banner width to height ratio from the design (near-square cards).
const double bannerAspectRatio = 2;

/// Flex weight for the centered tag/title region.
const int _copyFlex = 50;

/// Flex weight for the bottom inset photo region.
const int _insetFlex = 48;

/// Opacity of the sprinkle dashes on the colored shell.
const double _sprinkleOpacity = 0.28;

/// Approximate sprinkle count for the decorative pattern.
const int _sprinkleCount = 28;

/// How far the shop glyph sits above the inset photo.
const double _shopGlyphOverlapFactor = 0.45;

/// Height of the banner carousel for a given host width.
double bannerCarouselHeightForWidth(double width) => width / bannerAspectRatio;

/// Height of every [BannerCard] for a given card width.
double bannerCardHeightForWidth(double cardWidth) =>
    cardWidth / (bannerViewportFraction * bannerAspectRatio);

class BannerCard extends StatelessWidget {
  const BannerCard({required this.banner, super.key});

  final HomeBanner banner;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SizedBox(
      height: bannerCardHeightForWidth(constraints.maxWidth),
      child: _BannerShell(banner: banner),
    ),
  );
}

class _BannerShell extends StatelessWidget {
  const _BannerShell({required this.banner});

  final HomeBanner banner;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: context.layout.horizontalGutter,
        end: spacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.xl),
        ),
        child: ColoredBox(
          color: context.colors.bannerShell(banner.cardTone),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: _SprinklePainter(
                    color: context.colors.onPrimary.withValues(
                      alpha: _sprinkleOpacity,
                    ),
                  ),
                ),
              ),
              _BannerBody(banner: banner),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerBody extends StatelessWidget {
  const _BannerBody({required this.banner});

  final HomeBanner banner;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      children: [
        Expanded(
          flex: _copyFlex,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: spacing.lg,
              end: spacing.lg,
              top: spacing.sm,
            ),
            child: _BannerCopy(banner: banner),
          ),
        ),
        Expanded(
          flex: _insetFlex,
          child: _InsetPhoto(banner: banner),
        ),
      ],
    );
  }
}

class _BannerCopy extends StatelessWidget {
  const _BannerCopy({required this.banner});

  final HomeBanner banner;

  @override
  Widget build(BuildContext context) {
    final tag = banner.tag;
    final hasTag = tag != null && tag.isNotEmpty;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasTag) ...[
          _BannerTag(label: tag),
          SizedBox(height: context.spacing.xs),
        ],
        Flexible(
          child: Text(
            banner.title,
            textAlign: TextAlign.center,
            style: context.typography.title.copyWith(
              color: context.colors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _BannerTag extends StatelessWidget {
  const _BannerTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.highlight,
      borderRadius: context.radius.pillAll,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.xs,
      ),
      child: Text(
        label,
        style: context.typography.label.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

class _InsetPhoto extends StatelessWidget {
  const _InsetPhoto({required this.banner});

  final HomeBanner banner;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final glyphExtent = context.iconSizes.lg;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: spacing.lg,
        end: spacing.lg,
      ),
      child: _InsetPhotoStack(banner: banner, glyphExtent: glyphExtent),
    );
  }
}

class _InsetPhotoStack extends StatelessWidget {
  const _InsetPhotoStack({required this.banner, required this.glyphExtent});

  final HomeBanner banner;
  final double glyphExtent;

  @override
  Widget build(BuildContext context) {
    final topPad = glyphExtent * _shopGlyphOverlapFactor;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: EdgeInsets.only(top: topPad),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.radius.lg),
            ),
            child: AppImage(
              image: ImageRef.fromSources(
                asset: banner.imageAsset,
                url: banner.imageUrl,
              ),
              semanticLabel: banner.title,
            ),
          ),
        ),
        Positioned(top: 0, child: _ShopGlyph(extent: glyphExtent)),
      ],
    );
  }
}

class _ShopGlyph extends StatelessWidget {
  const _ShopGlyph({required this.extent});

  final double extent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      shape: BoxShape.circle,
      boxShadow: context.shadows.card,
    ),
    child: SizedBox.square(
      dimension: extent,
      child: Icon(
        Icons.storefront_rounded,
        size: context.iconSizes.md,
        color: context.colors.accent,
      ),
    ),
  );
}

class _SprinklePainter extends CustomPainter {
  _SprinklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.shortestSide * _sprinkleStrokeFactor
      ..strokeCap = StrokeCap.round;
    final random = math.Random(_sprinkleSeed);
    for (var i = 0; i < _sprinkleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final angle = random.nextDouble() * math.pi;
      final length = size.shortestSide * _sprinkleLengthFactor;
      final dx = math.cos(angle) * length;
      final dy = math.sin(angle) * length;
      canvas.drawLine(Offset(x - dx, y - dy), Offset(x + dx, y + dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SprinklePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Deterministic seed so sprinkles do not reshuffle on repaint.
const int _sprinkleSeed = 42;

/// Dash length relative to the card's shortest side.
const double _sprinkleLengthFactor = 0.035;

/// Dash stroke relative to the card's shortest side.
const double _sprinkleStrokeFactor = 0.012;
