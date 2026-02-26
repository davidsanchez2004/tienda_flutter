import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/presentation/providers/product_provider.dart';
import 'package:by_arena/data/repositories/product_repository.dart';
import 'package:by_arena/domain/models/product.dart';
import 'package:by_arena/presentation/widgets/product_card.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';

final offersProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.getProducts(onOffer: true, limit: 100);
});

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.arenaPale,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 14),
              title: const Text(
                'Ofertas Especiales',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.arenaPale, AppColors.sand],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -30,
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
                          const SizedBox(height: 60),
                          Icon(Icons.local_offer_rounded,
                              size: 36,
                              color: AppColors.arena.withValues(alpha: 0.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Subtitle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Descuentos exclusivos en productos seleccionados',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // ── Products ──
          offersAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.arenaPale,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_offer_outlined,
                              size: 48, color: AppColors.arena),
                        ),
                        const SizedBox(height: 16),
                        const Text('No hay ofertas activas',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('¡Vuelve pronto para encontrar chollos!',
                            style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () => context.go('/catalogo'),
                          child: const Text('Ver catálogo completo'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => ProductCard(
                      product: products[i],
                      onTap: () => context.push('/producto/${products[i].id}'),
                    ),
                    childCount: products.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: ShimmerGrid()),
            error: (e, _) => SliverToBoxAdapter(
              child: ErrorDisplay(
                message: 'Error al cargar ofertas',
                onRetry: () => ref.invalidate(offersProvider),
              ),
            ),
          ),

          // ── Newsletter banner ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              color: AppColors.arena,
              child: Column(
                children: [
                  const Text(
                    '¿Buscas algo específico?',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Suscríbete para recibir ofertas exclusivas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/contacto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.arena,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                    ),
                    child: const Text('Contactar',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
