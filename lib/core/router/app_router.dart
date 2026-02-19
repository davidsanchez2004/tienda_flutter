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
import 'package:by_arena/presentation/screens/checkout/checkout_success_screen.dart';
import 'package:by_arena/presentation/screens/orders/orders_screen.dart';
import 'package:by_arena/presentation/screens/orders/order_detail_screen.dart';
import 'package:by_arena/presentation/screens/returns/return_request_screen.dart';
import 'package:by_arena/presentation/screens/tracking/tracking_screen.dart';
import 'package:by_arena/presentation/screens/auth/login_screen.dart';
import 'package:by_arena/presentation/screens/auth/register_screen.dart';
import 'package:by_arena/presentation/screens/auth/forgot_password_screen.dart';
import 'package:by_arena/presentation/screens/search/search_screen.dart';
import 'package:by_arena/presentation/screens/offers/offers_screen.dart';
import 'package:by_arena/presentation/screens/blog/blog_list_screen.dart';
import 'package:by_arena/presentation/screens/blog/blog_detail_screen.dart';
import 'package:by_arena/presentation/screens/contact/contact_screen.dart';
import 'package:by_arena/presentation/screens/info/faq_screen.dart';
import 'package:by_arena/presentation/screens/info/about_screen.dart';
import 'package:by_arena/presentation/screens/info/legal_screen.dart';
import 'package:by_arena/presentation/screens/address/address_management_screen.dart';
import 'package:by_arena/presentation/screens/admin/admin_login_screen.dart';
import 'package:by_arena/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:by_arena/presentation/screens/admin/admin_orders_screen.dart';
import 'package:by_arena/presentation/screens/admin/admin_products_screen.dart';
import 'package:by_arena/presentation/screens/admin/admin_categories_screen.dart';
import 'package:by_arena/presentation/screens/admin/admin_returns_screen.dart';
import 'package:by_arena/presentation/screens/admin/admin_discounts_screen.dart';
import 'package:by_arena/presentation/screens/admin/admin_blog_screen.dart';
import 'package:by_arena/presentation/screens/admin/admin_newsletter_screen.dart';

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
        path: '/checkout-exitoso',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CheckoutSuccessScreen(
          sessionId: state.uri.queryParameters['session_id'],
        ),
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
        path: '/recuperar-contrasena',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/buscar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/ofertas',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OffersScreen(),
      ),
      GoRoute(
        path: '/blog',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BlogListScreen(),
      ),
      GoRoute(
        path: '/blog/:slug',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => BlogDetailScreen(
          slug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/contacto',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/faq',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/sobre-nosotros',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/terminos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LegalScreen.terms(),
      ),
      GoRoute(
        path: '/privacidad',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LegalScreen.privacy(),
      ),
      GoRoute(
        path: '/cookies',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LegalScreen.cookies(),
      ),
      GoRoute(
        path: '/devoluciones-info',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LegalScreen.returns(),
      ),
      GoRoute(
        path: '/mis-direcciones',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddressManagementScreen(),
      ),
      // Admin routes
      GoRoute(
        path: '/admin-login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin-panel',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin-orders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin-products',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin-categories',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminCategoriesScreen(),
      ),
      GoRoute(
        path: '/admin-returns',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminReturnsScreen(),
      ),
      GoRoute(
        path: '/admin-discounts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminDiscountsScreen(),
      ),
      GoRoute(
        path: '/admin-blog',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminBlogScreen(),
      ),
      GoRoute(
        path: '/admin-newsletter',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminNewsletterScreen(),
      ),
    ],
  );
});
