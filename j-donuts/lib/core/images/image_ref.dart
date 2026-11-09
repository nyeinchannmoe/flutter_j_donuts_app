import 'package:flutter/foundation.dart';

/// Where an image comes from. Network images always carry a bundled
/// fallback so first launch without network still renders.
@immutable
sealed class ImageRef {
  const ImageRef();

  /// Prefers [url] when present, falling back to the bundled [asset].
  factory ImageRef.fromSources({required String asset, String? url}) =>
      url == null || url.isEmpty
      ? AssetImageRef(asset)
      : NetworkImageRef(url: url, fallbackAsset: asset);
}

final class AssetImageRef extends ImageRef {
  const AssetImageRef(this.path);

  final String path;

  @override
  bool operator ==(Object other) =>
      other is AssetImageRef && other.path == path;

  @override
  int get hashCode => path.hashCode;
}

final class NetworkImageRef extends ImageRef {
  const NetworkImageRef({required this.url, required this.fallbackAsset});

  final String url;
  final String fallbackAsset;

  @override
  bool operator ==(Object other) =>
      other is NetworkImageRef &&
      other.url == url &&
      other.fallbackAsset == fallbackAsset;

  @override
  int get hashCode => Object.hash(url, fallbackAsset);
}
