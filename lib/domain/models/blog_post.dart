class BlogPost {
  final String id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String? coverImage;
  final String? category;
  final String? author;
  final bool isPublished;
  final String? publishedAt;
  final String? createdAt;

  const BlogPost({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    this.coverImage,
    this.category,
    this.author,
    this.isPublished = true,
    this.publishedAt,
    this.createdAt,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      excerpt: json['excerpt'],
      content: json['content'],
      coverImage: json['cover_image'],
      category: json['category'],
      author: json['author'],
      isPublished: json['is_published'] ?? true,
      publishedAt: json['published_at'],
      createdAt: json['created_at'],
    );
  }
}
