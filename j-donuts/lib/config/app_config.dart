import 'package:jdonuts/config/app_environment.dart';

/// Compile-time configuration from `--dart-define` values.
///
/// The remote catalog is off by default; the app then runs entirely on the
/// bundled seed and local database.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.remoteEnabled,
    required this.apiBaseUrl,
    required this.reachabilityHost,
  });

  factory AppConfig.fromEnvironment() => AppConfig(
    environment: AppEnvironment.parse(
      const String.fromEnvironment(environmentKey),
    ),
    remoteEnabled: const bool.fromEnvironment(remoteEnabledKey),
    apiBaseUrl: const String.fromEnvironment(apiBaseUrlKey),
    reachabilityHost: const String.fromEnvironment(
      reachabilityHostKey,
      defaultValue: defaultReachabilityHost,
    ),
  );

  static const String environmentKey = 'ENVIRONMENT';
  static const String remoteEnabledKey = 'REMOTE_ENABLED';
  static const String apiBaseUrlKey = 'API_BASE_URL';
  static const String reachabilityHostKey = 'REACHABILITY_HOST';
  static const String defaultReachabilityHost = 'example.com';

  final AppEnvironment environment;
  final bool remoteEnabled;
  final String apiBaseUrl;
  final String reachabilityHost;

  /// Remote sync needs both the flag and a base URL.
  bool get usesRemoteCatalog => remoteEnabled && apiBaseUrl.isNotEmpty;
}
