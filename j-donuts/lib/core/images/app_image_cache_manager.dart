import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Disk cache for network images.
class AppImageCacheManager extends CacheManager with ImageCacheManager {
  AppImageCacheManager()
    : super(
        Config(
          cacheKey,
          stalePeriod: stalePeriod,
          maxNrOfCacheObjects: maxObjects,
        ),
      );

  static const String cacheKey = 'jdonuts_images';
  static const Duration stalePeriod = Duration(days: 30);
  static const int maxObjects = 400;
}

/// Makes the app's single image cache manager available to AppImage.
class ImageCacheScope extends InheritedWidget {
  const ImageCacheScope({
    required this.cacheManager,
    required super.child,
    super.key,
  });

  final BaseCacheManager cacheManager;

  static BaseCacheManager? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ImageCacheScope>()
      ?.cacheManager;

  @override
  bool updateShouldNotify(ImageCacheScope oldWidget) =>
      oldWidget.cacheManager != cacheManager;
}
