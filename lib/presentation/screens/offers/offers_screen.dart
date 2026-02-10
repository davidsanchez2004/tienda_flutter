import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/presentation/providers/product_provider.dart';
import 'package:by_arena/presentation/widgets/product_card.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';

final offersProvider = FutureProvider<List>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts(oferta: true);
});

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas')),
      body: offersAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_outlined, size: 64, color: AppColors.arenaLight),
                  const SizedBox(height: 16),
                  const Text('No hay ofertas activas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('¡Vuelve pronto para encontrar chollos!',
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
            itemBuilder: (ctx, i) => ProductCard(
              product: products[i],
              onTap: () => context.push('/producto/${products[i].id}'),
            ),
          );
        },
        loading: () => const ShimmerGrid(),
        error: (e, _) => ErrorDisplay(
          message: 'Error al cargar ofertas',
          onRetry: () => ref.invalidate(offersProvider),
        ),
      ),
    );
  }
}
