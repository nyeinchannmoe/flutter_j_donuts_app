import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/config/routes/route_paths.dart';
import 'package:jdonuts/config/routes/route_transitions.dart';
import 'package:jdonuts/core/di/injector.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/scaffold/placeholder_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/settings/settings_screen.dart';
import 'package:jdonuts/module/home/presentation/bloc/banners/banners_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_refresh/home_refresh_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_section/home_section_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/member_header/member_header_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/shops/shops_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/home_screen.dart';
import 'package:jdonuts/module/product/presentation/bloc/product_detail/product_detail_bloc.dart';
import 'package:jdonuts/module/product/presentation/screens/product_detail/product_detail_screen.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/challenges/challenges_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_summary/rewards_summary_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/tier_ladder/tier_ladder_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/rewards_screen.dart';

/// Tab branches in bottom navigation order.
List<StatefulShellBranch> shellBranches() => [
  StatefulShellBranch(routes: [_homeRoute()]),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: RoutePaths.explore,
        builder: (context, state) =>
            PlaceholderScreen(title: context.l10n.navMenu),
      ),
    ],
  ),
  StatefulShellBranch(routes: [_rewardsRoute()]),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: RoutePaths.orders,
        builder: (context, state) =>
            PlaceholderScreen(title: context.l10n.navOrders),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  ),
];

GoRoute _homeRoute() => GoRoute(
  path: RoutePaths.home,
  builder: (context, state) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<MemberHeaderBloc>()..add(const MemberHeaderStarted()),
      ),
      BlocProvider(
        create: (_) => getIt<BannersBloc>()..add(const BannersStarted()),
      ),
      BlocProvider(
        create: (_) => getIt<ShopsBloc>()..add(const ShopsStarted()),
      ),
      BlocProvider(create: (_) => getIt<HomeRefreshBloc>()),
    ],
    child: HomeScreen(
      sectionBlocFactory: (kind) =>
          getIt<HomeSectionBloc>(param1: kind)..add(const HomeSectionStarted()),
      onProductSelected: (id) => context.push(RoutePaths.productDetail(id)),
      onExploreNow: () => context.go(RoutePaths.explore),
      onOrderOnline: (_) => context.go(RoutePaths.explore),
    ),
  ),
);

GoRoute _rewardsRoute() => GoRoute(
  path: RoutePaths.rewards,
  builder: (context, state) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<RewardsSummaryBloc>()..add(const RewardsSummaryStarted()),
      ),
      BlocProvider(
        create: (_) => getIt<TierLadderBloc>()..add(const TierLadderStarted()),
      ),
      BlocProvider(
        create: (_) => getIt<ChallengesBloc>()..add(const ChallengesStarted()),
      ),
    ],
    child: const RewardsScreen(),
  ),
);

/// Product detail sits above the shell; unknown ids show not-found inside.
GoRoute productRoute() => GoRoute(
  path: RoutePaths.product,
  pageBuilder: (context, state) {
    final id = state.pathParameters[RoutePaths.productIdParam]!;
    return RouteTransitions.fadeScale(
      context,
      state,
      BlocProvider(
        create: (_) =>
            getIt<ProductDetailBloc>()..add(ProductDetailStarted(id)),
        child: ProductDetailScreen(productId: id),
      ),
    );
  },
);
