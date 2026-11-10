/// Hero tags shared between screens of different features.
abstract final class HeroTags {
  /// Source segment used by product detail so it can match a home tile hero.
  static const detailSource = 'detail';

  /// Unique product-image hero tag. [source] separates tiles that share an id.
  static String productImage(
    String productId, {
    String source = detailSource,
  }) => 'product-image-$source-$productId';
}
