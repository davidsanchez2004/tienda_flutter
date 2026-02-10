import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/presentation/providers/blog_provider.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';

class BlogDetailScreen extends ConsumerWidget {
  final String slug;
  const BlogDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(blogPostProvider(slug));

    return Scaffold(
      appBar: AppBar(),
      body: postAsync.when(
        data: (post) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.coverImage != null)
                CachedNetworkImage(
                  imageUrl: post.coverImage!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.arenaPale,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(post.category!,
                            style: const TextStyle(fontSize: 12, color: AppColors.arena)),
                      ),
                    Text(post.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    if (post.publishedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd MMMM yyyy', 'es').format(DateTime.parse(post.publishedAt!)),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Content (rendered as simple text — for full HTML use flutter_html package)
                    Text(
                      post.content ?? '',
                      style: const TextStyle(fontSize: 16, height: 1.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorDisplay(
          message: 'Error al cargar el artículo',
          onRetry: () => ref.invalidate(blogPostProvider(slug)),
        ),
      ),
    );
  }
}
