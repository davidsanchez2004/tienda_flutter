import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/presentation/providers/cart_provider.dart';
import 'package:by_arena/presentation/widgets/whatsapp_floating_button.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _routes = ['/', '/catalogo', '/carrito', '/perfil'];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: widget.child,
      floatingActionButton: const WhatsAppFloatingButton(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            context.go(_routes[index]);
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Catálogo',
            ),
            BottomNavigationBarItem(
              icon: cartCount > 0
                  ? badges.Badge(
                      badgeContent: Text(
                        '$cartCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: AppColors.gold,
                      ),
                      child: const Icon(Icons.shopping_bag_outlined),
                    )
                  : const Icon(Icons.shopping_bag_outlined),
              activeIcon: const Icon(Icons.shopping_bag),
              label: 'Carrito',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
