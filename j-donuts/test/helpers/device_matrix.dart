import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// One screen size and text scale combination.
class DeviceCase {
  const DeviceCase(this.name, this.size, this.textScale);

  final String name;
  final Size size;
  final double textScale;

  @override
  String toString() =>
      '$name ${size.width.toInt()}x${size.height.toInt()} '
      '@ text ${textScale}x';
}

/// Reference sizes at text scale 1.0 and 1.3. Layout overflow is reported
/// as a Flutter error, so any overflowing case fails its test.
abstract final class DeviceMatrix {
  static const Size smallPhone = Size(320, 568);
  static const Size shortPhone = Size(360, 640);
  static const Size phone = Size(390, 844);
  static const Size largePhone = Size(430, 932);
  static const Size tablet = Size(820, 1180);

  static const Map<String, Size> sizes = {
    'small phone': smallPhone,
    'short phone': shortPhone,
    'phone': phone,
    'large phone': largePhone,
    'tablet': tablet,
  };

  static const List<double> textScales = [1, 1.3];

  static final ValueVariant<DeviceCase> variant = ValueVariant({
    for (final entry in sizes.entries)
      for (final scale in textScales) DeviceCase(entry.key, entry.value, scale),
  });
}
