import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/presentation/providers/auth_provider.dart';
import 'package:by_arena/presentation/providers/wishlist_provider.dart';
import 'package:by_arena/presentation/widgets/product_card.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      ref.read(wishlistProvider.notifier).loadWishlist();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final wishlist = ref.watch(wishlistProvider);

    if (authState.status != AuthStatus.authenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favoritos')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_border, size: 64, color: AppColors.arenaLight),
                const SizedBox(height: 16),
                const Text('Inicia sesión para ver tus favoritos',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Iniciar Sesión'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: wishlist.isLoading
          ? const ShimmerGrid()
          : wishlist.error != null
              ? ErrorDisplay(
                  message: 'Error al cargar favoritos',
                  onRetry: () => ref.read(wishlistProvider.notifier).loadWishlist(),
                )
              : wishlist.items.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: () => ref.read(wishlistProvider.notifier).loadWishlist(),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: wishlist.items.length,
                        itemBuilder: (ctx, i) {
                          final product = wishlist.items[i];
                          return Stack(
                            children: [
                              ProductCard(
                                product: product,
                                onTap: () => context.push('/producto/${product.id}'),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => ref
                                      .read(wishlistProvider.notifier)
                                      .toggleWishlist(product),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.favorite,
                                        color: AppColors.error, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 64, color: AppColors.arenaLight),
          const SizedBox(height: 16),
          const Text('Tu lista de favoritos está vacía',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Añade productos que te gusten',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.go('/catalogo'),
            child: const Text('Explorar Catálogo'),
          ),
        ],
      ),
    );
  }
}
