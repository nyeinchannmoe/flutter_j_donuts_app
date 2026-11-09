import 'package:freezed_annotation/freezed_annotation.dart';

part 'tier.freezed.dart';

@freezed
abstract class Tier with _$Tier {
  const factory Tier({
    required String id,
    required String name,
    required int minPoints,
    required int rank,
  }) = _Tier;
}
