import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/data/repositories/blog_repository.dart';
import 'package:by_arena/domain/models/blog_post.dart';

final blogPostsProvider = FutureProvider<List<BlogPost>>((ref) async {
  final repo = ref.watch(blogRepositoryProvider);
  return repo.getPosts();
});

final blogPostProvider = FutureProvider.family<BlogPost, String>((ref, slug) async {
  final repo = ref.watch(blogRepositoryProvider);
  return repo.getPost(slug);
});
