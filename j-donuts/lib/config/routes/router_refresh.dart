import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapts a stream into the Listenable go_router uses to re-run redirects.
class RouterRefreshStream extends ChangeNotifier {
  RouterRefreshStream(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
