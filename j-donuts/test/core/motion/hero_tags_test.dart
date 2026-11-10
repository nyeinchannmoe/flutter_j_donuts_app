import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/transitions/hero_tags.dart';

void main() {
  test('product image tags stay unique across home section sources', () {
    const productId = 'p_santa_cookies';
    final seasonal = HeroTags.productImage(productId, source: 'sec_seasonal');
    final orderAgain = HeroTags.productImage(
      productId,
      source: 'sec_order_again',
    );

    expect(seasonal, isNot(orderAgain));
    expect(seasonal, 'product-image-sec_seasonal-$productId');
    expect(
      HeroTags.productImage(productId, source: HeroTags.detailSource),
      'product-image-${HeroTags.detailSource}-$productId',
    );
  });
}
