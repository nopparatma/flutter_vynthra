/// Build-time environment configuration.
///
/// Values come from `--dart-define-from-file=config/<env>.json`.
/// A build without that flag falls back to the defaults below.
class Env {
  Env._();

  static const String name = String.fromEnvironment('ENV_NAME', defaultValue: 'prod');
  static const String dbName = String.fromEnvironment('DB_NAME', defaultValue: 'vynthra');

  static bool get isProd => name == 'prod';
}
