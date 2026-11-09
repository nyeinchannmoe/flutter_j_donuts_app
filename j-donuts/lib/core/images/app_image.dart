import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image_cache_manager.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';

/// Renders an [ImageRef] decoded at the size it is laid out at.
///
/// Network images use the shared disk cache, show a skeleton while
/// loading and fall back to the bundled asset on error, so offline first
/// launches still show artwork.
class AppImage extends StatelessWidget {
  const AppImage({
    required this.image,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    super.key,
  });

  final ImageRef image;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cacheWidth = _decodeWidth(context, constraints);
      return switch (image) {
        AssetImageRef(:final path) => _asset(path, cacheWidth),
        NetworkImageRef(:final url, :final fallbackAsset) => CachedNetworkImage(
          imageUrl: url,
          cacheManager: ImageCacheScope.maybeOf(context),
          fit: fit,
          memCacheWidth: cacheWidth,
          placeholder: (context, _) => const SkeletonBlock(),
          errorWidget: (context, _, _) => _asset(fallbackAsset, cacheWidth),
        ),
      };
    },
  );

  Widget _asset(String path, int? cacheWidth) => Image.asset(
    path,
    fit: fit,
    cacheWidth: cacheWidth,
    semanticLabel: semanticLabel,
    excludeFromSemantics: semanticLabel == null,
    errorBuilder: (context, error, stackTrace) => _ImageErrorView(
      semanticLabel: semanticLabel,
    ),
  );

  static int? _decodeWidth(BuildContext context, BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth) return null;
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return (constraints.maxWidth * ratio).round();
  }
}

class _ImageErrorView extends StatelessWidget {
  const _ImageErrorView({this.semanticLabel});

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.surfaceMuted,
    child: Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: context.colors.textDisabled,
        size: context.iconSizes.md,
        semanticLabel: semanticLabel,
      ),
    ),
  );
}
