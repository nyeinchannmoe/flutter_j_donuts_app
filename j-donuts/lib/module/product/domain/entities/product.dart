import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String code,
    required String name,
    required int priceMmk,
    required bool isNew,
    required String imageAsset,
    required String description,
    String? imageUrl,
  }) = _Product;
}
