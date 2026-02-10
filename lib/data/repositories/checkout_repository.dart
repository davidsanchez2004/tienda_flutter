import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/core/network/api_exception.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return CheckoutRepository(ref.read(dioProvider));
});

class CheckoutRepository {
  final Dio _dio;
  CheckoutRepository(this._dio);

  Future<Map<String, dynamic>> createSession({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> customer,
    required String shippingMethod,
    required double shippingCost,
    required double subtotal,
    required double total,
    String? discountCode,
    String? userId,
  }) async {
    try {
      final body = <String, dynamic>{
        'items': items,
        'customer': customer,
        'shipping_method': shippingMethod,
        'shipping_cost': shippingCost,
        'subtotal': subtotal,
        'total': total,
      };
      if (discountCode != null) body['discountCode'] = discountCode;
      if (userId != null) body['user_id'] = userId;

      final response = await _dio.post('/checkout/create-session', data: body);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> validateDiscount({
    required String code,
    String? email,
    String? userId,
    double? cartTotal,
  }) async {
    try {
      final response = await _dio.post('/checkout/validate-discount', data: {
        'code': code,
        'email': email,
        'userId': userId,
        'cartTotal': cartTotal,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String sessionId,
    String? orderId,
  }) async {
    try {
      final response = await _dio.get('/checkout/verify-payment', queryParameters: {
        'session_id': sessionId,
        'order_id': orderId,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
