import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _ordersCount = 0;
  int _productsCount = 0;
  int _returnsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!AdminRepository.isAdminLoggedIn) {
      if (mounted) context.go('/admin-login');
      return;
    }
    try {
      final repo = ref.read(adminRepositoryProvider);
      final orders = await repo.getAllOrders();
      final products = await repo.getAllProducts();
      final returns = await repo.getReturns();
      if (mounted) {
        setState(() {
          _ordersCount = orders.length;
          _productsCount = products.length;
          _returnsCount = returns.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AdminRepository.logout();
              context.go('/perfil');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats cards
                  Row(
                    children: [
                      _StatCard(icon: Icons.shopping_bag, label: 'Pedidos', value: '$_ordersCount', color: AppColors.arena),
                      const SizedBox(width: 12),
                      _StatCard(icon: Icons.inventory_2, label: 'Productos', value: '$_productsCount', color: AppColors.gold),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatCard(icon: Icons.assignment_return, label: 'Devoluciones', value: '$_returnsCount', color: AppColors.warning),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text('Gestión', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  _AdminMenuTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Gestionar Pedidos',
                    subtitle: 'Ver, actualizar estado y tracking',
                    onTap: () => context.push('/admin-orders'),
                  ),
                  _AdminMenuTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Gestionar Productos',
                    subtitle: 'Crear, editar y eliminar productos',
                    onTap: () => context.push('/admin-products'),
                  ),
                  _AdminMenuTile(
                    icon: Icons.category_outlined,
                    title: 'Gestionar Categorías',
                    subtitle: 'Crear, editar y eliminar categorías',
                    onTap: () => context.push('/admin-categories'),
                  ),
                  _AdminMenuTile(
                    icon: Icons.assignment_return_outlined,
                    title: 'Devoluciones',
                    subtitle: 'Ver y gestionar solicitudes de devolución',
                    onTap: () => context.push('/admin-returns'),
                  ),
                  _AdminMenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Facturas',
                    subtitle: 'Ver, descargar y generar facturas',
                    onTap: () => context.push('/admin-invoices'),
                  ),
                  _AdminMenuTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Códigos de Descuento',
                    subtitle: 'Crear y gestionar descuentos',
                    onTap: () => context.push('/admin-discounts'),
                  ),
                  _AdminMenuTile(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Cupones Automáticos',
                    subtitle: 'Reglas de cupones por nivel de gasto',
                    onTap: () => context.push('/admin-auto-coupons'),
                  ),
                  _AdminMenuTile(
                    icon: Icons.article_outlined,
                    title: 'Blog',
                    subtitle: 'Gestionar artículos del blog',
                    onTap: () => context.push('/admin-blog'),
                  ),
                  _AdminMenuTile(
                    icon: Icons.mail_outlined,
                    title: 'Newsletter',
                    subtitle: 'Estadísticas de suscriptores',
                    onTap: () => context.push('/admin-newsletter'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.arenaLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.arenaPale,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.arena),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.arenaLight),
        ),
        tileColor: AppColors.white,
      ),
    );
  }
}
