import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/presentation/providers/product_provider.dart';
import 'package:by_arena/presentation/widgets/product_card.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';

IconData _categoryIcon(String slug) {
  switch (slug) {
    case 'bolsos':
      return Icons.shopping_bag_outlined;
    case 'collares':
      return Icons.auto_awesome_outlined;
    case 'pendientes':
      return Icons.diamond_outlined;
    case 'pulseras':
      return Icons.watch_outlined;
    case 'perfumes':
      return Icons.spa_outlined;
    case 'anillos':
      return Icons.circle_outlined;
    default:
      return Icons.star_outline_rounded;
  }
}


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with logo
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.push('/buscar'),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => context.push('/favoritos'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'BY ARENA',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppColors.textPrimary,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.arena, AppColors.cream],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.diamond_outlined,
                    size: 60,
                    color: AppColors.gold.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (categories) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      'Categorías',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).state = cat.id;
                            context.go('/catalogo');
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppColors.arenaPale, Color(0xFFF0E6D8)],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.arenaLight, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.arena.withOpacity(0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _categoryIcon(cat.slug ?? cat.name.toLowerCase()),
                                    color: AppColors.gold,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Featured products
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Destacados',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/catalogo'),
                    child: const Text('Ver todo →'),
                  ),
                ],
              ),
            ),
          ),

          featuredAsync.when(
            data: (products) => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/producto/${product.id}'),
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: ShimmerGrid()),
            error: (error, _) => SliverToBoxAdapter(
              child: ErrorDisplay(
                message: error.toString(),
                onRetry: () => ref.invalidate(featuredProductsProvider),
              ),
            ),
          ),

          // Quick actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.local_shipping_outlined,
                        label: 'Rastrear pedido',
                        onTap: () => context.push('/rastreo'),
                      ),
                      _QuickAction(
                        icon: Icons.assignment_return_outlined,
                        label: 'Devoluciones',
                        onTap: () => context.push('/mis-pedidos'),
                      ),
                      _QuickAction(
                        icon: Icons.headset_mic_outlined,
                        label: 'Contacto',
                        onTap: () => context.push('/contacto'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Free shipping banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.arenaPale,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.arenaLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_shipping, color: AppColors.gold, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Envío gratuito',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Text(
                                'En pedidos superiores a ${AppConfig.freeShippingThreshold.toStringAsFixed(0)}${AppConfig.currency}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.arenaPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.arena, size: 24),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
