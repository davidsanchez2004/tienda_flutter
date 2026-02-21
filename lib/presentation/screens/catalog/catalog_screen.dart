import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/presentation/providers/product_provider.dart';
import 'package:by_arena/presentation/widgets/product_card.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';
import 'package:by_arena/presentation/widgets/cart_icon_badge.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/buscar'),
          ),
          const CartIconBadge(),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Todos'),
                      selected: selectedCategory == null,
                      onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = null,
                      selectedColor: AppColors.arena,
                      labelStyle: TextStyle(
                        color: selectedCategory == null ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat.name),
                      selected: selectedCategory == cat.id,
                      onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state =
                          selectedCategory == cat.id ? null : cat.id,
                      selectedColor: AppColors.arena,
                      labelStyle: TextStyle(
                        color: selectedCategory == cat.id ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Products grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.arena),
                        SizedBox(height: 12),
                        Text('No hay productos en esta categoría',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/producto/${product.id}'),
                    );
                  },
                );
              },
              loading: () => const ShimmerGrid(),
              error: (error, _) => ErrorDisplay(
                message: error.toString(),
                onRetry: () => ref.invalidate(productsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
