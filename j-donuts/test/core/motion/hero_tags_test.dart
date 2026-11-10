import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/transitions/hero_tags.dart';

void main() {
  test('product image tags are stable and unique per product', () {
    expect(
      HeroTags.productImage('p_santa_cookies'),
      'product-image-p_santa_cookies',
    );
    expect(
      HeroTags.productImage('p_santa_cookies'),
      isNot(HeroTags.productImage('p_coconut')),
    );
  });
}
