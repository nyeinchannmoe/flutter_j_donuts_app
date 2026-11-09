import 'package:flutter/material.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/extensions/failure_localization.dart';

/// Localized failure message with a retry action when retrying can help.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.failure,
    this.onRetry,
    this.message,
    super.key,
  });

  final AppFailure failure;
  final VoidCallback? onRetry;

  /// Overrides the generic failure text, for example for not-found.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final retry = failure.isRetryable ? onRetry : null;
    return Padding(
      padding: EdgeInsets.all(context.spacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: context.iconSizes.lg,
            color: context.colors.danger,
          ),
          SizedBox(height: context.spacing.sm),
          Text(
            message ?? failure.localizedMessage(context.l10n),
            textAlign: TextAlign.center,
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          if (retry != null) ...[
            SizedBox(height: context.spacing.sm),
            TextButton(onPressed: retry, child: Text(context.l10n.actionRetry)),
          ],
        ],
      ),
    );
  }
}
