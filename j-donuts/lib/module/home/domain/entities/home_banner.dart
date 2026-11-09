import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_banner.freezed.dart';

@freezed
abstract class HomeBanner with _$HomeBanner {
  const factory HomeBanner({
    required String id,
    required String title,
    required String imageAsset,
    String? tag,
    String? imageUrl,
  }) = _HomeBanner;
}
