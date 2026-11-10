import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_section/home_section_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/section_products/widgets/section_product_grid.dart';
import 'package:jdonuts/module/home/presentation/screens/section_products/widgets/section_product_list.dart';
import 'package:jdonuts/module/home/presentation/screens/section_products/widgets/section_products_skeleton.dart';

/// Full catalog for one [HomeSectionKind]: list for seasonal, grid otherwise.
class SectionProductsScreen extends StatelessWidget {
  const SectionProductsScreen({
    required this.kind,
    required this.onProductSelected,
    super.key,
  });

  final HomeSectionKind kind;
  final ValueChanged<String> onProductSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: colors.textPrimary),
        title: _SectionTitle(kind: kind),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutMetrics.maxContentWidth,
            ),
            child: _SectionBody(
              kind: kind,
              onProductSelected: onProductSelected,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.kind});

  final HomeSectionKind kind;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeSectionBloc, ViewState<HomeSection>>(
        buildWhen: (previous, current) => previous != current,
        builder: (context, state) {
          final title = switch (state) {
            ViewData<HomeSection>(:final value) => value.title,
            _ => '',
          };
          return Text(title, style: context.typography.title);
        },
      );
}

class _SectionBody extends StatelessWidget {
  const _SectionBody({
    required this.kind,
    required this.onProductSelected,
  });

  final HomeSectionKind kind;
  final ValueChanged<String> onProductSelected;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeSectionBloc, ViewState<HomeSection>>(
        builder: (context, state) => ViewStateBuilder<HomeSection>(
          state: state,
          skeleton: SectionProductsSkeleton(kind: kind),
          emptyMessage: context.l10n.sectionEmpty,
          onRetry: () =>
              context.read<HomeSectionBloc>().add(const HomeSectionRetried()),
          builder: (context, section) => _SectionCatalog(
            section: section,
            onProductSelected: onProductSelected,
          ),
        ),
      );
}

class _SectionCatalog extends StatelessWidget {
  const _SectionCatalog({
    required this.section,
    required this.onProductSelected,
  });

  final HomeSection section;
  final ValueChanged<String> onProductSelected;

  @override
  Widget build(BuildContext context) {
    if (section.kind == HomeSectionKind.seasonal) {
      return SectionProductList(
        products: section.items,
        kind: section.kind,
        onProductSelected: onProductSelected,
      );
    }
    return SectionProductGrid(
      products: section.items,
      kind: section.kind,
      onProductSelected: onProductSelected,
    );
  }
}
