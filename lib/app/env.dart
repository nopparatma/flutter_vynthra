/// Build-time environment configuration.
///
/// Values come from `--dart-define-from-file=config/<env>.json`.
/// A build without that flag targets a backend running on this machine.
class Env {
  Env._();

  static const String name = String.fromEnvironment('ENV_NAME', defaultValue: 'local');

  /// Base URL of vynthra_service, without a trailing slash.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8787');

  static bool get isProd => name == 'prod';
}
