/// Central API configuration.
/// Override at build time:
///   flutter run --dart-define=API_BASE_URL=https://your-deployed-api.com
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // 10.0.2.2 → Android emulator loopback to host machine
    // Change to your machine's LAN IP when running on a physical device
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String predictEndpoint = '$baseUrl/predict';
}
