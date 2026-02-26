import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/presentation/providers/wishlist_provider.dart';
import 'package:by_arena/presentation/providers/cart_provider.dart';
import 'package:by_arena/presentation/providers/auth_provider.dart';
import 'package:by_arena/domain/models/cart_item.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.status != AuthStatus.authenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favoritos')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_border,
                    size: 64, color: AppColors.arenaLight),
                const SizedBox(height: 16),
                const Text('Inicia sesión para ver tus favoritos',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text(
                    'Guarda tus productos favoritos para comprarlos más tarde',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
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

    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Favoritos')),
      body: wishlistAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.arenaPale,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border,
                          size: 48, color: AppColors.arena),
                    ),
                    const SizedBox(height: 16),
                    const Text('No tienes favoritos aún',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text(
                      'Pulsa el corazón en los productos que te gusten para guardarlos aquí',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => context.go('/catalogo'),
                      child: const Text('Explorar Catálogo'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final product = item.product;
              if (product == null) return const SizedBox.shrink();

              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 28),
                ),
                onDismissed: (_) {
                  ref.read(wishlistProvider.notifier).toggle(product.id);
                },
                child: GestureDetector(
                  onTap: () => context.push('/producto/${product.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.arenaLight),
                    ),
                    child: Row(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                                width: 80,
                                height: 80,
                                color: AppColors.arenaPale),
                            errorWidget: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              color: AppColors.arenaPale,
                              child: const Icon(Icons.image_not_supported,
                                  color: AppColors.arena),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${product.effectivePrice.toStringAsFixed(2)}${AppConfig.currency}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: product.onOffer
                                          ? AppColors.error
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (product.onOffer &&
                                      product.offerPrice != null) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '${product.price.toStringAsFixed(2)}${AppConfig.currency}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.isAvailable ? 'En stock' : 'Agotado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: product.isAvailable
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Actions
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite,
                                  color: AppColors.error),
                              onPressed: () {
                                ref
                                    .read(wishlistProvider.notifier)
                                    .toggle(product.id);
                              },
                            ),
                            if (product.isAvailable)
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart,
                                    color: AppColors.arena),
                                onPressed: () {
                                  ref.read(cartProvider.notifier).addItem(
                                        CartItem(
                                          productId: product.id,
                                          name: product.name,
                                          imageUrl: product.imageUrl,
                                          quantity: 1,
                                          price: product.effectivePrice,
                                          stock: product.stock,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${product.name} añadido al carrito'),
                                      backgroundColor: AppColors.arena,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.arena)),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error: $error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.read(wishlistProvider.notifier).load(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
