import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/domain/models/product.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ref.watch(dioProvider));
});

class WishlistRepository {
  final Dio _dio;
  WishlistRepository(this._dio);

  Future<List<Product>> getWishlist() async {
    final res = await _dio.get('/api/wishlist');
    final items = res.data['wishlist'] as List? ?? [];
    return items.map((item) {
      // The API returns wishlist items with product data nested
      final productData = item['product'] ?? item;
      return Product.fromJson(productData);
    }).toList();
  }

  Future<void> addToWishlist(String productId) async {
    await _dio.post('/api/wishlist', data: {'productId': productId});
  }

  Future<void> removeFromWishlist(String productId) async {
    await _dio.delete('/api/wishlist', data: {'productId': productId});
  }
}
