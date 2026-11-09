/// Build flavour selected with `--dart-define=ENVIRONMENT=<name>`.
enum AppEnvironment {
  development,
  staging,
  production;

  /// Unknown names fall back to development so local runs need no flags.
  static AppEnvironment parse(String name) => AppEnvironment.values.firstWhere(
    (environment) => environment.name == name,
    orElse: () => AppEnvironment.development,
  );
}
