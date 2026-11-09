import 'package:get_it/get_it.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/module/rewards/data/datasources/rewards_catalog_importers.dart';
import 'package:jdonuts/module/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:jdonuts/module/rewards/domain/repositories/rewards_repository.dart';
import 'package:jdonuts/module/rewards/domain/usecases/watch_challenges.dart';
import 'package:jdonuts/module/rewards/domain/usecases/watch_tiers.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/challenges/challenges_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_summary/rewards_summary_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/tier_ladder/tier_ladder_bloc.dart';

List<CatalogImporter> rewardsCatalogImporters(GetIt locator) {
  final database = locator<AppDatabase>();
  return [
    TiersCatalogImporter(database.memberDao),
    ChallengesCatalogImporter(database.challengesDao),
  ];
}

void registerRewardsModule(GetIt locator) {
  final database = locator<AppDatabase>();
  locator
    ..registerLazySingleton<RewardsRepository>(
      () => RewardsRepositoryImpl(
        memberDao: database.memberDao,
        challengesDao: database.challengesDao,
        logger: locator(),
      ),
    )
    ..registerFactory(() => WatchTiers(locator()))
    ..registerFactory(() => WatchChallenges(locator()))
    ..registerFactory(
      () => RewardsSummaryBloc(watchMemberProfile: locator()),
    )
    ..registerFactory(() => TierLadderBloc(watchTiers: locator()))
    ..registerFactory(() => ChallengesBloc(watchChallenges: locator()));
}
