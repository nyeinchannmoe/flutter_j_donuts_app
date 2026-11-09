import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/sync/sync_status.dart';

/// Shows one non-blocking message whenever a sync fails. Cached content
/// stays on screen.
class SyncFailureListener extends StatefulWidget {
  const SyncFailureListener({
    required this.status,
    required this.messengerKey,
    required this.child,
    super.key,
  });

  final Stream<SyncStatus> status;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  State<SyncFailureListener> createState() => _SyncFailureListenerState();
}

class _SyncFailureListenerState extends State<SyncFailureListener> {
  StreamSubscription<SyncStatus>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.status
        .where((status) => status is SyncFailed)
        .listen((_) => _showFailure());
  }

  void _showFailure() {
    if (!mounted) return;
    widget.messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.syncFailed)));
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
