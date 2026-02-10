/// API base URL – change this to your production domain
class AppConfig {
  // Servidor del instituto:
  static const String apiBaseUrl = 'http://byarena.victoriafp.online/api';
  // Desarrollo local (Android emulator → host):
  // static const String apiBaseUrl = 'http://10.0.2.2:4321/api';

  /// Base URL del servidor (sin /api) para resolver rutas relativas de imágenes
  static const String siteBaseUrl = 'http://byarena.victoriafp.online';

  /// Resuelve una URL de imagen: si es relativa la convierte a absoluta
  static String resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '$siteBaseUrl$url';
  }

  static const String appName = 'BY ARENA';
  static const String currency = '€';
  static const String whatsappNumber = '+34600000000';
  static const double freeShippingThreshold = 50.0;
  static const double shippingCost = 4.95;
}
