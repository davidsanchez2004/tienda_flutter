import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.status != AuthStatus.authenticated) {
      return _buildUnauthenticated(context);
    }

    final user = authState.user!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.arena, AppColors.arenaLight],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Text(
                          (user.fullName.isNotEmpty)
                              ? user.fullName[0].toUpperCase()
                              : user.email[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.arena,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : user.email,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mi Cuenta',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  _ProfileTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Mis Pedidos',
                    subtitle: 'Consulta el estado de tus pedidos',
                    onTap: () => context.push('/mis-pedidos'),
                  ),
                  _ProfileTile(
                    icon: Icons.favorite_border,
                    title: 'Favoritos',
                    subtitle: 'Productos que te gustan',
                    onTap: () => context.push('/favoritos'),
                  ),
                  _ProfileTile(
                    icon: Icons.local_shipping_outlined,
                    title: 'Rastrear Pedido',
                    subtitle: 'Sigue el estado de tu envío',
                    onTap: () => context.push('/rastreo'),
                  ),
                  _ProfileTile(
                    icon: Icons.location_on_outlined,
                    title: 'Mis Direcciones',
                    subtitle: 'Gestiona tus direcciones de envío',
                    onTap: () => context.push('/mis-direcciones'),
                  ),
                  _ProfileTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Ofertas',
                    subtitle: 'Productos en oferta',
                    onTap: () => context.push('/ofertas'),
                  ),

                  const SizedBox(height: 24),
                  const Text('Información',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  _ProfileTile(
                    icon: Icons.article_outlined,
                    title: 'Blog',
                    subtitle: 'Novedades y artículos',
                    onTap: () => context.push('/blog'),
                  ),
                  _ProfileTile(
                    icon: Icons.info_outline,
                    title: 'Sobre Nosotros',
                    subtitle: 'Conoce BY ARENA',
                    onTap: () => context.push('/sobre-nosotros'),
                  ),

                  const SizedBox(height: 24),
                  const Text('Soporte',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  _ProfileTile(
                    icon: Icons.help_outline,
                    title: 'Preguntas Frecuentes',
                    subtitle: 'Resuelve tus dudas',
                    onTap: () => context.push('/faq'),
                  ),
                  _ProfileTile(
                    icon: Icons.mail_outlined,
                    title: 'Contacto',
                    subtitle: 'Escríbenos para cualquier consulta',
                    onTap: () => context.push('/contacto'),
                  ),

                  const SizedBox(height: 24),
                  const Text('Legal',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  _ProfileTile(
                    icon: Icons.description_outlined,
                    title: 'Términos y Condiciones',
                    onTap: () => context.push('/terminos'),
                  ),
                  _ProfileTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Política de Privacidad',
                    onTap: () => context.push('/privacidad'),
                  ),
                  _ProfileTile(
                    icon: Icons.cookie_outlined,
                    title: 'Política de Cookies',
                    onTap: () => context.push('/cookies'),
                  ),
                  _ProfileTile(
                    icon: Icons.assignment_return_outlined,
                    title: 'Política de Devoluciones',
                    onTap: () => context.push('/devoluciones-info'),
                  ),

                  const SizedBox(height: 32),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cerrar sesión'),
                            content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Cerrar sesión',
                                    style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go('/');
                        }
                      },
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text('Cerrar Sesión',
                          style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'BY ARENA v1.0.0',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticated(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, size: 64, color: AppColors.arenaLight),
              const SizedBox(height: 16),
              const Text('Accede a tu cuenta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text(
                'Inicia sesión para gestionar tus pedidos, favoritos y más',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/registro'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
                child: const Text('Crear Cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.arena),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
