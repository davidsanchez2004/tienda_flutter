import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/presentation/providers/blog_provider.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';

class BlogListScreen extends ConsumerWidget {
  const BlogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(blogPostsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Blog')),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: AppColors.arenaLight),
                  const SizedBox(height: 16),
                  const Text('Próximamente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Estamos preparando contenido para ti',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (ctx, i) {
              final post = posts[i];
              return GestureDetector(
                onTap: () => context.push('/blog/${post.slug}'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.arenaLight),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.coverImage != null)
                        CachedNetworkImage(
                          imageUrl: post.coverImage!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.arenaPale,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(post.category!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.arena)),
                              ),
                            const SizedBox(height: 8),
                            Text(post.title,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            if (post.excerpt != null) ...[
                              const SizedBox(height: 6),
                              Text(post.excerpt!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            ],
                            if (post.publishedAt != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('dd MMM yyyy', 'es').format(DateTime.parse(post.publishedAt!)),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const ShimmerList(),
        error: (e, _) => ErrorDisplay(
          message: 'Error al cargar el blog',
          onRetry: () => ref.invalidate(blogPostsProvider),
        ),
      ),
    );
  }
}
