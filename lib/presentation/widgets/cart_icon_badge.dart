import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/presentation/providers/cart_provider.dart';

/// Icono de carrito con badge reactivo que muestra el número de items.
/// Se usa en los AppBars de las pantallas principales.
class CartIconBadge extends ConsumerWidget {
  const CartIconBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return IconButton(
      icon: cartCount > 0
          ? badges.Badge(
              badgeContent: Text(
                '$cartCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: AppColors.gold,
                padding: EdgeInsets.all(4),
              ),
              child: const Icon(Icons.shopping_bag_outlined),
            )
          : const Icon(Icons.shopping_bag_outlined),
      onPressed: () => context.go('/carrito'),
      tooltip: 'Carrito',
    );
  }
}
