class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      final data = error.response?.data;
      final msg = data is Map ? (data['error'] ?? data['message'] ?? 'Error desconocido') : 'Error del servidor';
      return ApiException(msg, statusCode: error.response?.statusCode);
    }
    if (error.type.toString().contains('connectionTimeout') ||
        error.type.toString().contains('receiveTimeout')) {
      return ApiException('Tiempo de espera agotado. Verifica tu conexión.');
    }
    return ApiException('Error de conexión. Verifica tu red.');
  }
}
