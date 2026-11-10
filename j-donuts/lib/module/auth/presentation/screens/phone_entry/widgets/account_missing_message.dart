import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

/// Inline log-in failure with a register link that keeps the entered number.
class AccountMissingMessage extends StatefulWidget {
  const AccountMissingMessage({required this.onRegister, super.key});

  final VoidCallback onRegister;

  @override
  State<AccountMissingMessage> createState() => _AccountMissingMessageState();
}

class _AccountMissingMessageState extends State<AccountMissingMessage> {
  late final TapGestureRecognizer _registerLink =
      TapGestureRecognizer()..onTap = widget.onRegister;

  @override
  void didUpdateWidget(covariant AccountMissingMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registerLink.onTap = widget.onRegister;
  }

  @override
  void dispose() {
    _registerLink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final danger = context.typography.caption.copyWith(
      color: context.colors.danger,
    );
    return Padding(
      padding: EdgeInsets.only(top: context.spacing.xs),
      child: Semantics(
        liveRegion: true,
        child: Text.rich(
          TextSpan(
            style: danger,
            children: [
              TextSpan(text: l10n.failureAccountMissingBefore),
              TextSpan(
                text: l10n.failureAccountMissingLink,
                style: danger.copyWith(color: context.colors.accent),
                recognizer: _registerLink,
              ),
              TextSpan(text: l10n.failureAccountMissingAfter),
            ],
          ),
        ),
      ),
    );
  }
}
