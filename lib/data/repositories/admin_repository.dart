import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/core/network/api_exception.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(dioProvider));
});

class AdminRepository {
  final Dio _dio;
  AdminRepository(this._dio);

  // ─── Analytics ────────────────────────────────────
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await _dio.get('/admin/analytics',
          options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Products ─────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final response = await _dio.get('/admin/get-all-products',
          options: Options(headers: {'x-admin-key': _adminKey}));
      final list = (response.data['products'] as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/create-product',
          data: data, options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateProduct(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/update-product?id=$id',
          data: data, options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('/admin/delete-product?id=$id',
          options: Options(headers: {'x-admin-key': _adminKey}));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Categories ───────────────────────────────────
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get('/admin/categories',
          options: Options(headers: {'x-admin-key': _adminKey}));
      final list = (response.data['categories'] as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/categories',
          data: data, options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateCategory(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/categories?id=$id',
          data: data, options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('/admin/categories?id=$id',
          options: Options(headers: {'x-admin-key': _adminKey}));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Orders ───────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final response = await _dio.get('/admin/get-orders',
          options: Options(headers: {'x-admin-key': _adminKey}));
      final list =
          (response.data['orders'] as List?) ?? (response.data as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/admin/orders/$id',
          data: data, options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateTracking(
      String orderId, String trackingNumber, String carrier) async {
    try {
      final response = await _dio.post('/admin/update-tracking',
          data: {
            'orderId': orderId,
            'trackingNumber': trackingNumber,
            'carrier': carrier,
          },
          options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Returns ──────────────────────────────────────
  Future<List<Map<String, dynamic>>> getReturns() async {
    try {
      final response = await _dio.get('/admin/get-returns',
          options: Options(headers: {'x-admin-key': _adminKey}));
      final list =
          (response.data['returns'] as List?) ?? (response.data as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateReturn({
    required String returnId,
    required String status,
    String? adminNotes,
    String? refundStatus,
  }) async {
    try {
      final response = await _dio.patch('/admin/update-return',
          data: {
            'returnId': returnId,
            'status': status,
            if (adminNotes != null) 'adminNotes': adminNotes,
            if (refundStatus != null) 'refundStatus': refundStatus,
          },
          options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Invoices (removed – replaced by Dashboard analytics) ─────

  // ─── Upload Image ─────────────────────────────────
  Future<String> uploadImage(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _dio.post('/admin/upload-image',
          data: formData,
          options: Options(headers: {
            'x-admin-key': _adminKey,
            'Content-Type': 'multipart/form-data',
          }));
      return response.data['url'] ?? '';
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Auto Coupon Rules ────────────────────────────
  Future<List<Map<String, dynamic>>> getAutoCouponRules() async {
    try {
      final response = await _dio.get('/admin/auto-coupon-rules',
          options: Options(headers: {'x-admin-key': _adminKey}));
      final list = (response.data['rules'] as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createAutoCouponRule(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/auto-coupon-rules',
          data: data, options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> toggleAutoCouponRule(String id, bool isActive) async {
    try {
      await _dio.put('/admin/auto-coupon-rules',
          data: {'id': id, 'is_active': isActive},
          options: Options(headers: {'x-admin-key': _adminKey}));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteAutoCouponRule(String id) async {
    try {
      await _dio.delete('/admin/auto-coupon-rules',
          data: {'id': id},
          options: Options(headers: {'x-admin-key': _adminKey}));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Discount Codes ───────────────────────────────
  Future<List<Map<String, dynamic>>> getDiscountCodes() async {
    try {
      final response = await _dio.get('/admin/discount-codes',
          options: Options(headers: {'x-admin-key': _adminKey}));
      final list = (response.data['codes'] as List?) ??
          (response.data['discount_codes'] as List?) ??
          (response.data as List?) ??
          [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createDiscountCode(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/discount-codes',
          data: data, options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteDiscountCode(String id) async {
    try {
      await _dio.delete('/admin/discount-codes?id=$id',
          options: Options(headers: {'x-admin-key': _adminKey}));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Blog ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getBlogPosts() async {
    try {
      final response = await _dio.get('/admin/blog',
          options: Options(headers: {'x-admin-key': _adminKey}));
      final list = (response.data['posts'] as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createBlogPost(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/admin/blog',
          data: data, options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateBlogPost(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/admin/blog?id=$id',
          data: data, options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteBlogPost(String id) async {
    try {
      await _dio.delete('/admin/blog?id=$id',
          options: Options(headers: {'x-admin-key': _adminKey}));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Newsletter ───────────────────────────────────
  Future<Map<String, dynamic>> getNewsletterStats() async {
    try {
      final response = await _dio.get('/admin/newsletter',
          options: Options(headers: {'x-admin-key': _adminKey}));
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ─── Admin Login ──────────────────────────────────
  static String _adminKey = '';

  static void setAdminKey(String key) {
    _adminKey = key;
  }

  static String get adminKey => _adminKey;

  static bool get isAdminLoggedIn => _adminKey.isNotEmpty;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/admin/login', data: {
        'email': email,
        'password': password,
      });
      if (response.data['success'] == true) {
        _adminKey = password;
        return true;
      }
      return false;
    } on DioException {
      return false;
    }
  }

  static void logout() {
    _adminKey = '';
  }
}
