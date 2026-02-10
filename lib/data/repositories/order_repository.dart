import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/core/network/api_exception.dart';
import 'package:by_arena/domain/models/order.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.read(dioProvider));
});

class OrderRepository {
  final Dio _dio;
  OrderRepository(this._dio);

  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _dio.get('/orders/my-orders');
      final list = (response.data['orders'] as List?) ?? [];
      return list.map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Order> getOrderDetail(String id) async {
    try {
      final response = await _dio.get('/orders/$id');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Order> findByNumber({required String orderNumber, required String email}) async {
    try {
      final response = await _dio.get('/orders/find-by-number', queryParameters: {
        'orderNumber': orderNumber,
        'email': email,
      });
      return Order.fromJson(response.data['order']);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> customer,
    required String shippingMethod,
    required double shippingCost,
    required double subtotal,
    required double total,
  }) async {
    try {
      final response = await _dio.post('/orders/create', data: {
        'items': items,
        'customer': customer,
        'shipping_method': shippingMethod,
        'shipping_cost': shippingCost,
        'subtotal': subtotal,
        'total': total,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> trackOrder({required String email, required String orderId}) async {
    try {
      final response = await _dio.post('/tracking/search-order', data: {
        'email': email,
        'orderId': orderId,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
