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

/// Banner width to height ratio from the design (near-square cards).
const double _bannerAspectRatio = 1.02;

/// Leaves a peek of the next banner when more than one exists.
const double _bannerViewportFraction = 0.86;

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: _bannerAspectRatio,
    child: BlocBuilder<BannersBloc, ViewState<List<HomeBanner>>>(
      builder: (context, state) => ViewStateBuilder<List<HomeBanner>>(
        state: state,
        skeleton: SkeletonBlock(borderRadius: context.radius.xlAll),
        emptyMessage: context.l10n.bannersEmpty,
        onRetry: () => context.read<BannersBloc>().add(const BannersRetried()),
        builder: (context, banners) =>
            _BannerPager(key: ValueKey(banners.length), banners: banners),
      ),
    ),
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
    viewportFraction: _bannerViewportFraction,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carousel.updateProfile(context.motion);
  }

  @override
  void dispose() {
    _carousel.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _carousel.pauseForInteraction();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: PageView.builder(
          controller: _carousel.pageController,
          itemCount: widget.banners.length,
          padEnds: false,
          itemBuilder: (context, index) =>
              BannerCard(banner: widget.banners[index]),
        ),
      );
}
