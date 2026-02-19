import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/domain/models/blog_post.dart';

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  return BlogRepository(ref.watch(dioProvider));
});

class BlogRepository {
  final Dio _dio;
  BlogRepository(this._dio);

  Future<List<BlogPost>> getPosts({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    final res = await _dio.get('/blog', queryParameters: params);
    final list = res.data['posts'] as List? ?? [];
    return list.map((e) => BlogPost.fromJson(e)).toList();
  }

  Future<BlogPost> getPost(String slug) async {
    final res = await _dio.get('/blog/$slug');
    return BlogPost.fromJson(res.data['post']);
  }
}
