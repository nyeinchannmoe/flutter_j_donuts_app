import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/home/domain/entities/home_banner.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';

/// Home content, read only from the local database.
abstract interface class HomeRepository {
  Stream<Result<List<HomeBanner>>> watchBanners();

  /// Emits null when the section does not exist.
  Stream<Result<HomeSection?>> watchSection(HomeSectionKind kind);

  Stream<Result<List<Shop>>> watchShops();

  /// Asks for fresh content. Cached content stays visible on failure.
  Future<Result<Unit>> refresh();
}
