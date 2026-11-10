import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_refresh/home_refresh_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_section/home_section_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/banner_carousel.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/member_header.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/nearby_shops.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/product_rail.dart';

/// Home: member header, banners, three product rails and nearby shops.
///
/// Each section listens to its own Bloc. Rails get theirs from
/// [sectionBlocFactory] because the same Bloc type appears three times.
/// Refresh failures are reported by the app-level sync listener.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.sectionBlocFactory,
    required this.onProductSelected,
    super.key,
  });

  final HomeSectionBloc Function(HomeSectionKind kind) sectionBlocFactory;
  final ValueChanged<String> onProductSelected;

  Future<void> _refresh(BuildContext context) {
    final bloc = context.read<HomeRefreshBloc>()
      ..add(const HomeRefreshRequested());
    return bloc.stream.firstWhere((state) => !state.isRefreshing);
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      const _Gutter(child: MemberHeader()),
      const BannerCarousel(),
      for (final kind in HomeSectionKind.values)
        BlocProvider<HomeSectionBloc>(
          key: ValueKey(kind),
          create: (_) => sectionBlocFactory(kind),
          child: ProductRail(onProductSelected: onProductSelected),
        ),
      const _Gutter(child: NearbyShops()),
    ];
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: _SectionList(sections: sections),
        ),
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.sections});

  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return StaggeredEntrance(
      itemCount: sections.length,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LayoutMetrics.maxContentWidth,
          ),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: spacing.lg),
            itemCount: sections.length,
            separatorBuilder: (_, _) => SizedBox(height: spacing.xl),
            itemBuilder: (context, index) =>
                StaggeredItem(index: index, child: sections[index]),
          ),
        ),
      ),
    );
  }
}

/// Rails and banners scroll edge to edge; other sections sit in the gutter.
class _Gutter extends StatelessWidget {
  const _Gutter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: context.layout.horizontalGutter),
    child: child,
  );
}
