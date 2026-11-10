import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/primitives/auto_play_carousel_controller.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/domain/entities/home_banner.dart';
import 'package:jdonuts/module/home/presentation/bloc/banners/banners_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/banner_card.dart';

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SizedBox(
      height: bannerCarouselHeightForWidth(constraints.maxWidth),
      child: BlocBuilder<BannersBloc, ViewState<List<HomeBanner>>>(
        builder: (context, state) => ViewStateBuilder<List<HomeBanner>>(
          state: state,
          skeleton: const _BannerCarouselSkeleton(),
          emptyMessage: context.l10n.bannersEmpty,
          onRetry: () =>
              context.read<BannersBloc>().add(const BannersRetried()),
          builder: (context, banners) =>
              _BannerPager(key: ValueKey(banners.length), banners: banners),
        ),
      ),
    ),
  );
}

/// Primary banner card plus a peek of the next card.
const int _bannerSkeletonCardCount = 2;

class _BannerCarouselSkeleton extends StatelessWidget {
  const _BannerCarouselSkeleton();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = bannerCarouselHeightForWidth(constraints.maxWidth);
      final cardWidth = constraints.maxWidth * bannerViewportFraction;
      final gutter = context.layout.horizontalGutter;
      final spacing = context.spacing;
      return SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.only(start: gutter),
          itemCount: _bannerSkeletonCardCount,
          separatorBuilder: (_, _) => SizedBox(width: spacing.sm),
          itemBuilder: (context, index) => SkeletonBlock(
            width: cardWidth - gutter,
            height: height,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(context.radius.xl),
            ),
          ),
        ),
      );
    },
  );
}

class _BannerPager extends StatefulWidget {
  const _BannerPager({required this.banners, super.key});

  final List<HomeBanner> banners;

  @override
  State<_BannerPager> createState() => _BannerPagerState();
}

class _BannerPagerState extends State<_BannerPager> {
  late final AutoPlayCarouselController _carousel = AutoPlayCarouselController(
    pageCount: widget.banners.length,
    viewportFraction: bannerViewportFraction,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carousel.updateProfile(
      context.motion,
      tickersEnabled: TickerMode.valuesOf(context).enabled,
    );
  }

  @override
  void dispose() {
    _carousel.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0 &&
        notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _carousel.pauseForInteraction();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(context.radius.xl),
    ),
    child: NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: PageView.builder(
        controller: _carousel.pageController,
        itemCount: widget.banners.length,
        padEnds: false,
        itemBuilder: (context, index) =>
            BannerCard(banner: widget.banners[index]),
      ),
    ),
  );
}
