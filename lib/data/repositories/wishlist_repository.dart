import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/core/network/api_exception.dart';
import 'package:by_arena/domain/models/wishlist_item.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ref.read(dioProvider));
});

class WishlistRepository {
  final Dio _dio;
  WishlistRepository(this._dio);

  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await _dio.get('/wishlist');
      final list = (response.data['items'] as List?) ?? [];
      return list.map((json) => WishlistItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> addToWishlist(String productId) async {
    try {
      await _dio.post('/wishlist', data: {'product_id': productId});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      await _dio.delete('/wishlist', data: {'product_id': productId});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
