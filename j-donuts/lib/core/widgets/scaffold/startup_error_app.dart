import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';

/// Full-screen, retryable error shown when the local database cannot be
/// prepared. The app never crashes on a failed seed.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({required this.onRetry, super.key});

  final FutureOr<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: _StartupErrorScreen(onRetry: onRetry),
  );
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.onRetry});

  final FutureOr<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(context.layout.horizontalGutter),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: context.spacing.lg,
          children: _content(context),
        ),
      ),
    ),
  );

  List<Widget> _content(BuildContext context) {
    final l10n = context.l10n;
    return [
      Icon(
        Icons.storage_rounded,
        size: context.iconSizes.illustration,
        color: context.colors.danger,
      ),
      Text(
        l10n.startupErrorTitle,
        textAlign: TextAlign.center,
        style: context.typography.headline,
      ),
      Text(
        l10n.startupErrorMessage,
        textAlign: TextAlign.center,
        style: context.typography.body,
      ),
      AppButton(label: l10n.actionRetry, onPressed: onRetry),
    ];
  }
}
