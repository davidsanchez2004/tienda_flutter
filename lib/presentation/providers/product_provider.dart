import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/data/repositories/product_repository.dart';
import 'package:by_arena/domain/models/product.dart';
import 'package:by_arena/domain/models/category.dart';

// Featured products (falls back to recent products if none are featured)
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  final featured = await repo.getProducts(featured: true, limit: 10);
  if (featured.isNotEmpty) return featured;
  // Fallback: show most recent products
  return repo.getProducts(limit: 10);
});

// All products (with optional category filter)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  final categoryId = ref.watch(selectedCategoryProvider);
  return repo.getProducts(categoryId: categoryId, limit: 50);
});

// Categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.getCategories();
});

// Product detail
final productDetailProvider = FutureProvider.family<Product, String>((ref, id) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.getProductById(id);
});

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final repo = ref.read(productRepositoryProvider);
  return repo.searchProducts(query: query);
});
