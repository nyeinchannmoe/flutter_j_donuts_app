import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/core/widgets/buttons/back_tile_button.dart';

class StepPageScaffold extends StatelessWidget {
  const StepPageScaffold({
    required this.title,
    required this.onBack,
    required this.progress,
    required this.content,
    this.action,
    this.supportingContent,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final Widget progress;
  final Widget content;

  /// Primary bottom action. Omit on steps that submit automatically.
  final Widget? action;
  final Widget? supportingContent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final gradient = colors.authGradient;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightSystemBars,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: gradient.begin,
            end: gradient.end,
            colors: [gradient.colors.first, colors.surface],
          ),
        ),
        child: Scaffold(
          backgroundColor: AppTheme.lightSystemBars.statusBarColor,
          body: SafeArea(
            child: StaggeredEntrance(
              itemCount: 3,
              child: _layout(context, keyboardOpen),
            ),
          ),
        ),
      ),
    );
  }

  Widget _layout(BuildContext context, bool keyboardOpen) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xl + spacing.xs + spacing.xxs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: SingleChildScrollView(child: _body(context))),
          StaggeredItem(index: 2, child: _actions(context, keyboardOpen)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: spacing.xl + spacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BackTileButton(onPressed: onBack),
            progress,
          ],
        ),
        SizedBox(height: spacing.xxl),
        StaggeredItem(
          index: 0,
          child: Semantics(
            header: true,
            child: Text(title, style: context.typography.headline),
          ),
        ),
        SizedBox(height: spacing.xxl + spacing.xxs),
        StaggeredItem(index: 1, child: content),
      ],
    );
  }

  Widget _actions(BuildContext context, bool keyboardOpen) {
    final spacing = context.spacing;
    final showLegal = !keyboardOpen && supportingContent != null;
    if (action == null && !showLegal) {
      return SizedBox(height: keyboardOpen ? spacing.md : spacing.xxl);
    }
    return Padding(
      padding: EdgeInsets.only(
        top: spacing.sm,
        bottom: keyboardOpen ? spacing.md : spacing.xxl + spacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?action,
          if (showLegal) ...[
            if (action != null) SizedBox(height: spacing.xxl + spacing.md),
            supportingContent!,
          ],
        ],
      ),
    );
  }
}
