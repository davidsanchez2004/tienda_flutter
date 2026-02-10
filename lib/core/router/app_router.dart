import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/presentation/screens/main_shell.dart';
import 'package:by_arena/presentation/screens/home/home_screen.dart';
import 'package:by_arena/presentation/screens/catalog/catalog_screen.dart';
import 'package:by_arena/presentation/screens/cart/cart_screen.dart';
import 'package:by_arena/presentation/screens/profile/profile_screen.dart';
import 'package:by_arena/presentation/screens/product/product_detail_screen.dart';
import 'package:by_arena/presentation/screens/checkout/checkout_screen.dart';
import 'package:by_arena/presentation/screens/orders/orders_screen.dart';
import 'package:by_arena/presentation/screens/orders/order_detail_screen.dart';
import 'package:by_arena/presentation/screens/returns/return_request_screen.dart';
import 'package:by_arena/presentation/screens/tracking/tracking_screen.dart';
import 'package:by_arena/presentation/screens/auth/login_screen.dart';
import 'package:by_arena/presentation/screens/auth/register_screen.dart';
import 'package:by_arena/presentation/screens/search/search_screen.dart';
import 'package:by_arena/presentation/screens/wishlist/wishlist_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/catalogo',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CatalogScreen(),
            ),
          ),
          GoRoute(
            path: '/carrito',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
          GoRoute(
            path: '/perfil',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/producto/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ProductDetailScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/mis-pedidos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/pedido/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/devolucion/:orderId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ReturnRequestScreen(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/rastreo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TrackingScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/registro',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/buscar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/favoritos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WishlistScreen(),
      ),
    ],
  );
});
