import 'package:by_arena/core/config/app_config.dart';

class Category {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image_url'] as String?;
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      imageUrl: rawImage != null ? AppConfig.resolveImageUrl(rawImage) : null,
    );
  }
}
