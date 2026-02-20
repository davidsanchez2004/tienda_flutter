import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/core/network/api_exception.dart';
import 'package:by_arena/data/local/auth_storage.dart';
import 'package:by_arena/domain/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider), ref.read(authStorageProvider));
});

class AuthRepository {
  final Dio _dio;
  final AuthStorage _storage;
  AuthRepository(this._dio, this._storage);

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final session = AuthSession.fromJson(response.data['session']);
      await _storage.saveTokens(session.accessToken, session.refreshToken);

      final user = User.fromJson(response.data['user']);
      await _storage.saveUser(id: user.id, email: user.email, name: user.fullName);

      return user;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone': phone,
      });

      final sessionData = response.data['session'];
      if (sessionData != null) {
        final session = AuthSession.fromJson(sessionData);
        await _storage.saveTokens(session.accessToken, session.refreshToken);
      }

      final user = User.fromJson(response.data['user']);
      await _storage.saveUser(id: user.id, email: user.email, name: user.fullName);

      return user;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null) return null;

      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data['user']);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() => _storage.isLoggedIn();

  /// Send password reset email via /api/auth/forgot-password
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// After registration, claim guest orders matching this email
  Future<int> claimGuestOrders({required String userId, required String email}) async {
    try {
      final response = await _dio.post('/orders/claim-guest-orders', data: {
        'userId': userId,
        'email': email,
      });
      return response.data['claimedCount'] ?? 0;
    } on DioException catch (e) {
      // Non-critical: don't throw, just return 0
      print('[AuthRepo] Error claiming guest orders: $e');
      return 0;
    }
  }
}
