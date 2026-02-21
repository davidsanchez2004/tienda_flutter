import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/presentation/providers/product_provider.dart';
import 'package:by_arena/presentation/providers/cart_provider.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';
import 'package:by_arena/presentation/widgets/cart_icon_badge.dart';
import 'package:by_arena/domain/models/cart_item.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      body: productAsync.when(
        data: (product) {
          final images = [product.imageUrl, ...product.imagesUrls];
          final hasDiscount = product.onOffer && product.offerPrice != null;

          return CustomScrollView(
            slivers: [
              // Image gallery
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: const [
                  CartIconBadge(),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: PageView.builder(
                    onPageChanged: (index) => setState(() => _selectedImageIndex = index),
                    itemCount: images.length,
                    itemBuilder: (context, index) => CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.arenaPale),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.arenaPale,
                        child: const Icon(Icons.image_not_supported, size: 48, color: AppColors.arena),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dot indicators
                      if (images.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(images.length, (i) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _selectedImageIndex ? AppColors.arena : AppColors.arenaLight,
                            ),
                          )),
                        ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.effectivePrice.toStringAsFixed(2)}${AppConfig.currency}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: hasDiscount ? AppColors.error : AppColors.textPrimary,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 10),
                            Text(
                              '${product.price.toStringAsFixed(2)}${AppConfig.currency}',
                              style: const TextStyle(
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Stock info
                      Row(
                        children: [
                          Icon(
                            product.isAvailable ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: product.isAvailable ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            product.isAvailable
                                ? (product.stock <= 5 ? '¡Últimas ${product.stock} unidades!' : 'En stock')
                                : 'Agotado',
                            style: TextStyle(
                              fontSize: 13,
                              color: product.isAvailable
                                  ? (product.stock <= 5 ? AppColors.warning : AppColors.success)
                                  : AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quantity selector
                      if (product.isAvailable) ...[
                        const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Builder(builder: (context) {
                          final cartItems = ref.watch(cartProvider);
                          final inCart = cartItems.where((i) => i.productId == product.id).fold(0, (sum, i) => sum + i.quantity);
                          final availableToAdd = (product.stock - inCart).clamp(0, product.stock);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove,
                                    onTap: () {
                                      if (_quantity > 1) setState(() => _quantity--);
                                    },
                                  ),
                                  Container(
                                    width: 48,
                                    alignment: Alignment.center,
                                    child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    enabled: _quantity < availableToAdd,
                                    onTap: () {
                                      if (_quantity < availableToAdd) setState(() => _quantity++);
                                    },
                                  ),
                                ],
                              ),
                              if (inCart > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Ya tienes $inCart en el carrito',
                                    style: const TextStyle(fontSize: 12, color: AppColors.warning),
                                  ),
                                ),
                            ],
                          );
                        }),
                        const SizedBox(height: 20),
                      ],

                      // Add to cart
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: product.isAvailable
                              ? () {
                                  ref.read(cartProvider.notifier).addItem(
                                    CartItem(
                                      productId: product.id,
                                      name: product.name,
                                      imageUrl: product.imageUrl,
                                      quantity: _quantity,
                                      price: product.effectivePrice,
                                      stock: product.stock,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.name} añadido al carrito'),
                                      backgroundColor: AppColors.arena,
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: 'Ver carrito',
                                        textColor: Colors.white,
                                        onPressed: () => context.go('/carrito'),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: Text(product.isAvailable ? 'Añadir al carrito' : 'No disponible'),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.arena)),
        error: (error, _) => ErrorDisplay(
          message: error.toString(),
          onRetry: () => ref.invalidate(productDetailProvider(widget.productId)),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _QtyButton({required this.icon, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.arenaLight, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
