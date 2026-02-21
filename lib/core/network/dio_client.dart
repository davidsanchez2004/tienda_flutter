import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/data/local/auth_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    responseType: ResponseType.plain,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(_JsonParseInterceptor());
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (o) => print('[API] $o'),
  ));

  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final storage = _ref.read(authStorageProvider);
    final token = await storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final storage = _ref.read(authStorageProvider);
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
          final response = await dio.post('/auth/refresh', data: {
            'refresh_token': refreshToken,
          });

          final newToken = response.data['session']['access_token'];
          final newRefresh = response.data['session']['refresh_token'];
          await storage.saveTokens(newToken, newRefresh);

          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          await storage.clearAll();
        }
      }
    }
    handler.next(err);
  }
}

/// Interceptor que parsea las respuestas plain-text a JSON.
/// Detecta respuestas HTML (bloqueo ISP, errores de servidor) y lanza error claro.
class _JsonParseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final raw = response.data;
    if (raw is String) {
      final trimmed = raw.trim();

      // Detectar HTML (bloqueo de ISP, páginas de error, etc.)
      if (trimmed.startsWith('<!DOCTYPE') || trimmed.startsWith('<html') || trimmed.startsWith('<')) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'El servidor no está disponible. Tu operador de internet puede estar bloqueando el acceso. Prueba con datos móviles o una VPN.',
          ),
        );
        return;
      }

      // Parsear JSON
      if (trimmed.isNotEmpty) {
        try {
          response.data = json.decode(trimmed);
        } catch (_) {
          // Si no es JSON válido, dejar como string
        }
      }
    }
    handler.next(response);
  }
}
