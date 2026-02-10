import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/core/network/api_exception.dart';

final returnRepositoryProvider = Provider<ReturnRepository>((ref) {
  return ReturnRepository(ref.read(dioProvider));
});

class ReturnRepository {
  final Dio _dio;
  ReturnRepository(this._dio);

  Future<Map<String, dynamic>> createReturnRequest({
    required String orderId,
    required String reason,
    required String description,
    String? guestEmail,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final body = <String, dynamic>{
        'orderId': orderId,
        'reason': reason,
        'description': description,
      };
      if (guestEmail != null) body['guestEmail'] = guestEmail;
      if (items != null) body['items'] = items;

      final response = await _dio.post('/returns/create-request', data: body);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
