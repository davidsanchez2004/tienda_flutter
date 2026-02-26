import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            expandedHeight: 280,
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
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.arena.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 50),
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.arena.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Nueva Colección 2026',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.diamond_outlined,
                              size: 40,
                              color: AppColors.gold.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bisutería premium y complementos\nelegantes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  AppColors.textPrimary.withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                              height: 1.4,
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

          // ── CTA Buttons ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _CtaButton(
                      label: 'Explorar Catálogo',
                      onTap: () => context.go('/catalogo'),
                      filled: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CtaButton(
                      label: 'Ver Ofertas',
                      onTap: () => context.push('/ofertas'),
                      filled: false,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Promo Banner ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D2D2D), Color(0xFF4A4A4A)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded,
                      color: AppColors.gold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, height: 1.3),
                        children: [
                          const TextSpan(
                            text: 'Envío gratuito ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text:
                                'en pedidos +${AppConfig.freeShippingThreshold.toStringAsFixed(0)}${AppConfig.currency}',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      color: Colors.white.withValues(alpha: 0.5), size: 14),
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
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 6),
                    child: _SectionHeader(
                      title: 'Nuestras Categorías',
                      subtitle:
                          'Explora nuestra colección de bisutería y accesorios premium',
                    ),
                  ),
                  const SizedBox(height: 8),
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
                            ref.read(selectedCategoryProvider.notifier).state =
                                cat.id;
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
                                  color: gradient.last.withValues(alpha: 0.3),
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
                                    color: Colors.white.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _categoryIcon(slug),
                                    color: AppColors.textPrimary
                                        .withValues(alpha: 0.7),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
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
              padding: const EdgeInsets.fromLTRB(16, 36, 16, 4),
              child: Column(
                children: [
                  // Pill badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            size: 16, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          'Selección Especial',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SectionHeader(
                    title: 'Productos Destacados',
                    subtitle:
                        'Nuestra selección curada de las piezas más especiales',
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.go('/catalogo'),
                      icon: const Text('Ver todo',
                          style: TextStyle(fontSize: 13)),
                      label: const Icon(Icons.arrow_forward_rounded, size: 16),
                    ),
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

          // ── View All Catalog Button ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: OutlinedButton(
                onPressed: () => context.go('/catalogo'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.arena, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ver Todo el Catálogo',
                  style: TextStyle(
                    color: AppColors.arena,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),

          // ── Why Choose Us ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
              child: Column(
                children: [
                  _SectionHeader(
                    title: '¿Por qué elegirnos?',
                    subtitle: null,
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.95,
                    children: const [
                      _BenefitCard(
                        icon: Icons.verified_outlined,
                        title: 'Calidad Premium',
                        desc:
                            'Materiales seleccionados para durabilidad y elegancia',
                        color: Color(0xFFF5F1ED),
                      ),
                      _BenefitCard(
                        icon: Icons.palette_outlined,
                        title: 'Diseño Exclusivo',
                        desc:
                            'Colecciones únicas diseñadas con pasión y detalle',
                        color: Color(0xFFFEF9C3),
                      ),
                      _BenefitCard(
                        icon: Icons.local_shipping_outlined,
                        title: 'Envío Rápido',
                        desc: 'Envío gratis +50€. Entrega en 2-3 días hábiles',
                        color: Color(0xFFE0E7FF),
                      ),
                      _BenefitCard(
                        icon: Icons.check_circle_outline,
                        title: 'Garantía Total',
                        desc: 'Devolución sin preguntas en 30 días garantizada',
                        color: Color(0xFFD1FAE5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Quick Actions ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    color: AppColors.arenaLight.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuickAction(
                        icon: Icons.local_shipping_outlined,
                        label: 'Rastrear Pedido',
                        color: const Color(0xFFE0E7FF),
                        iconColor: const Color(0xFF6366F1),
                        onTap: () => context.push('/rastreo'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.assignment_return_outlined,
                        label: 'Devoluciones',
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
                ],
              ),
            ),
          ),

          // ── Newsletter Section ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 36, 0, 0),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              color: AppColors.arena,
              child: Column(
                children: [
                  const Text(
                    'Suscríbete a Nuestro Newsletter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recibe ofertas exclusivas y un 10% de descuento en tu primera compra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tu email...',
                            style: TextStyle(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => context.push('/contacto'),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Suscribirse',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Social Links ──
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.arenaPale,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    'Síguenos en Redes',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Únete a nuestra comunidad y descubre las últimas tendencias',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        icon: Icons.camera_alt_rounded,
                        label: '@by__arena',
                        gradient: const [Color(0xFF833AB4), Color(0xFFE1306C)],
                        url: 'https://instagram.com/by__arena',
                      ),
                      const SizedBox(width: 12),
                      _SocialButton(
                        icon: Icons.music_note_rounded,
                        label: '@by__arena',
                        gradient: const [Color(0xFF000000), Color(0xFF333333)],
                        url: 'https://tiktok.com/@by__arena',
                      ),
                    ],
                  ),
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

// ── Section header ──
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ── CTA Button ──
class _CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _CtaButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? AppColors.arena : Colors.transparent,
          border: Border.all(
            color: AppColors.arena,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppColors.arena.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.white : AppColors.arena,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// ── Benefit Card ──
class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.arena, size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action (fixed alignment) ──
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Social Button ──
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final String url;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
