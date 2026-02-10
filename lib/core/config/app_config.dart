/// API base URL – change this to your production domain
class AppConfig {
  static const String apiBaseUrl = 'https://your-domain.com/api';
  // For local development:
  // static const String apiBaseUrl = 'http://10.0.2.2:4321/api'; // Android emulator
  // static const String apiBaseUrl = 'http://localhost:4321/api'; // iOS simulator

  static const String appName = 'BY ARENA';
  static const String currency = '€';
  static const String whatsappNumber = '+34600000000';
  static const double freeShippingThreshold = 50.0;
  static const double shippingCost = 4.95;
}
