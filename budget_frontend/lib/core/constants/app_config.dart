class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = 'https://budgetbackend-mu.vercel.app/api';

  /// Web OAuth client ID. Must be one of the IDs in the backend's GOOGLE_CLIENT_IDS.
  /// Override at build time: `--dart-define=GOOGLE_SERVER_CLIENT_ID=<id>.apps.googleusercontent.com`
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '668877744444-tnmlhbmciv0ar75nsl4cva7dhih3dt3b.apps.googleusercontent.com',
  );
}
