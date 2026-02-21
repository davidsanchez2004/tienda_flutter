class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      // Si el error ya tiene un mensaje customizado (ej: interceptor HTML)
      if (error.error is String && (error.error as String).isNotEmpty) {
        return ApiException(error.error, statusCode: error.response?.statusCode);
      }
      final data = error.response?.data;
      final msg = data is Map ? (data['error'] ?? data['message'] ?? 'Error desconocido') : 'Error del servidor';
      return ApiException(msg, statusCode: error.response?.statusCode);
    }
    // Error sin response (timeout, sin conexión, interceptor)
    if (error.error is String && (error.error as String).isNotEmpty) {
      return ApiException(error.error);
    }
    if (error.type.toString().contains('connectionTimeout') ||
        error.type.toString().contains('receiveTimeout')) {
      return ApiException('Tiempo de espera agotado. Verifica tu conexión.');
    }
    if (error.type.toString().contains('connectionError')) {
      return ApiException('No se pudo conectar al servidor. Verifica tu conexión a internet.');
    }
    return ApiException('Error de conexión. Verifica tu red.');
  }
}
