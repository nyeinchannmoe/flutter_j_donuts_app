import 'dart:async';
import 'dart:io';

/// Confirms that the internet is actually reachable, not just that a
/// network interface is up.
abstract interface class ReachabilityChecker {
  Future<bool> isReachable();
}

/// Resolves [host] through DNS within [timeout].
class DnsReachabilityChecker implements ReachabilityChecker {
  const DnsReachabilityChecker({
    required this.host,
    this.timeout = defaultTimeout,
  });

  static const Duration defaultTimeout = Duration(seconds: 3);

  final String host;
  final Duration timeout;

  @override
  Future<bool> isReachable() async {
    try {
      final addresses = await InternetAddress.lookup(host).timeout(timeout);
      return addresses.any((address) => address.rawAddress.isNotEmpty);
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}
