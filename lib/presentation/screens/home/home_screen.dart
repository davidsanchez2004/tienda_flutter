import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/presentation/providers/product_provider.dart';
import 'package:by_arena/presentation/widgets/product_card.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';
import 'package:by_arena/presentation/widgets/cart_icon_badge.dart';

IconData _categoryIcon(String slug) {
  switch (slug) {
    case 'collares':
      return Icons.all_inclusive_outlined;
    case 'pulseras':
      return Icons.trip_origin;
    case 'pendientes':
      return Icons.water_drop_outlined;
    case 'bolsos':
      return Icons.shopping_bag_outlined;
    case 'perfumes':
      return Icons.science_outlined;
    case 'anillos':
      return Icons.circle_outlined;
    case 'otros':
      return Icons.play_arrow_outlined;
    default:
      return Icons.star_outline_rounded;
  }
}

List<Color> _categoryGradient(String slug) {
  switch (slug) {
    case 'collares':
      return [const Color(0xFFFEF9C3), const Color(0xFFFDE68A)];
    case 'pulseras':
      return [const Color(0xFFFFE4E6), const Color(0xFFFDA4AF)];
    case 'pendientes':
      return [const Color(0xFFE0E7FF), const Color(0xFFC7D2FE)];
    case 'bolsos':
      return [const Color(0xFFFFEDD5), const Color(0xFFFDBA74)];
    case 'perfumes':
      return [const Color(0xFFFCE7F3), const Color(0xFFF9A8D4)];
    case 'anillos':
      return [const Color(0xFFD1FAE5), const Color(0xFF6EE7B7)];
    case 'otros':
      return [const Color(0xFFCCFBF1), const Color(0xFF5EEAD4)];
    default:
      return [const Color(0xFFF5F5F5), const Color(0xFFE5E5E5)];
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
          // ── Hero AppBar ──
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.cream,
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, size: 26),
                onPressed: () => context.push('/buscar'),
              ),
              const CartIconBadge(),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 14),
              title: const Text(
                'BY ARENA',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: AppColors.textPrimary,
                  letterSpacing: 3,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8DDD3),
                      AppColors.cream,
                      Color(0xFFF5EFE6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -40,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.arena.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 50),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.diamond_outlined,
                              size: 40,
                              color: AppColors.gold.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Promo Banner ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D2D2D), Color(0xFF4A4A4A)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, color: AppColors.gold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                        children: [
                          const TextSpan(
                            text: 'Envío gratuito ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: 'en pedidos +${AppConfig.freeShippingThreshold.toStringAsFixed(0)}${AppConfig.currency}',
                            style: TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.5), size: 14),
                ],
              ),
            ),
          ),

          // ── Categories ──
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (categories) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Categorías',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final slug = cat.slug ?? cat.name.toLowerCase();
                        final gradient = _categoryGradient(slug);
                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).state = cat.id;
                            context.go('/catalogo');
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradient,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: gradient.last.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _categoryIcon(slug),
                                    color: AppColors.textPrimary.withOpacity(0.7),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    cat.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
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
              loading: () => const SizedBox(height: 130),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // ── Featured Products header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Destacados',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/catalogo'),
                    icon: const Text('Ver todo', style: TextStyle(fontSize: 13)),
                    label: const Icon(Icons.arrow_forward_rounded, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // ── Featured Products grid ──
          featuredAsync.when(
            data: (products) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
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

          // ── Quick Actions ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    color: AppColors.arenaLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.local_shipping_outlined,
                        label: 'Rastrear\npedido',
                        color: const Color(0xFFE0E7FF),
                        iconColor: const Color(0xFF6366F1),
                        onTap: () => context.push('/rastreo'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.assignment_return_outlined,
                        label: 'Devolu-\nciones',
                        color: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFF97316),
                        onTap: () => context.push('/mis-pedidos'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.headset_mic_outlined,
                        label: 'Contacto',
                        color: const Color(0xFFD1FAE5),
                        iconColor: const Color(0xFF10B981),
                        onTap: () => context.push('/contacto'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.local_offer_outlined,
                        label: 'Ofertas',
                        color: const Color(0xFFFFE4E6),
                        iconColor: const Color(0xFFF43F5E),
                        onTap: () => context.push('/ofertas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
