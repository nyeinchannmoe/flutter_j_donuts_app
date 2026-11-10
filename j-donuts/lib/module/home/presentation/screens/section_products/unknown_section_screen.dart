import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/state_views/empty_state_view.dart';

/// Fallback when `/section/:kind` does not match a known home section kind.
class UnknownSectionScreen extends StatelessWidget {
  const UnknownSectionScreen({super.key});

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
      ),
      body: EmptyStateView(message: context.l10n.sectionEmpty),
    );
  }
}
