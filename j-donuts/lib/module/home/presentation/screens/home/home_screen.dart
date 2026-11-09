import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_refresh/home_refresh_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_section/home_section_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/home_header_band.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/nearby_shops.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/product_rail.dart';

/// Home: curved member header with banners, product rails and nearby shops.
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
      const HomeHeaderBand(),
      for (final kind in HomeSectionKind.values)
        BlocProvider<HomeSectionBloc>(
          key: ValueKey(kind),
          create: (_) => sectionBlocFactory(kind),
          child: ProductRail(onProductSelected: onProductSelected),
        ),
      // Full-bleed cyan band; insets live inside NearbyShops.
      const NearbyShops(),
    ];
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(context),
          edgeOffset: MediaQuery.paddingOf(context).top,
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
            padding: EdgeInsets.only(bottom: spacing.lg),
            itemCount: sections.length,
            separatorBuilder: (_, index) {
              final gap = index == 0 ? spacing.md : spacing.xl;
              return SizedBox(height: gap);
            },
            itemBuilder: (context, index) =>
                StaggeredItem(index: index, child: sections[index]),
          ),
        ),
      ),
    );
  }
}
