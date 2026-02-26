import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/core/network/api_exception.dart';
import 'package:by_arena/domain/models/product.dart';
import 'package:by_arena/domain/models/category.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(dioProvider));
});

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  Future<List<Product>> getProducts({
    String? categoryId,
    bool? featured,
    bool? onOffer,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limite': limit.toString(),
        'offset': offset.toString(),
      };
      if (categoryId != null) params['categoria'] = categoryId;
      if (featured == true) params['destacados'] = 'true';
      if (onOffer == true) params['oferta'] = 'true';

      final response = await _dio.get('/products', queryParameters: params);
      final data = response.data;
      final list = (data['products'] as List?) ?? [];
      return list.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/products/categories');
      final list = (response.data['categories'] as List?) ?? [];
      return list.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Product>> searchProducts({
    required String query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? onOffer,
    String sortBy = 'created_at',
    String sortDir = 'desc',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'q': query,
        'limite': limit.toString(),
        'offset': offset.toString(),
        'ordenar': sortBy,
        'direccion': sortDir,
      };
      if (categoryId != null) params['categoria'] = categoryId;
      if (minPrice != null) params['precio_min'] = minPrice.toString();
      if (maxPrice != null) params['precio_max'] = maxPrice.toString();
      if (onOffer == true) params['oferta'] = 'true';

      final response =
          await _dio.get('/products/search', queryParameters: params);
      final list = (response.data['products'] as List?) ?? [];
      return list.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> validateStock(
      List<Map<String, dynamic>> items) async {
    try {
      final response =
          await _dio.post('/products/stock', data: {'items': items});
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
