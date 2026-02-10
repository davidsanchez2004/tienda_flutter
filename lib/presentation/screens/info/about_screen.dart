import 'package:flutter/material.dart';
import 'package:by_arena/core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre Nosotros')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'BY ARENA',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: AppColors.arena,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nuestra Historia',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'BY ARENA nació de la pasión por la joyería artesanal y el diseño contemporáneo. '
              'Creamos piezas únicas que combinan materiales de alta calidad con diseños atemporales, '
              'pensadas para acompañarte en cada momento especial.',
              style: TextStyle(fontSize: 15, height: 1.7, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nuestros Valores',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _ValueCard(
              icon: Icons.diamond_outlined,
              title: 'Calidad Premium',
              desc: 'Seleccionamos cuidadosamente cada material para garantizar piezas duraderas y con acabados impecables.',
            ),
            _ValueCard(
              icon: Icons.eco_outlined,
              title: 'Sostenibilidad',
              desc: 'Nos comprometemos con prácticas responsables en cada etapa de producción.',
            ),
            _ValueCard(
              icon: Icons.favorite_border,
              title: 'Diseño con Alma',
              desc: 'Cada pieza cuenta una historia. Diseñamos con intención y cuidamos cada detalle.',
            ),
            _ValueCard(
              icon: Icons.local_shipping_outlined,
              title: 'Envío Cuidado',
              desc: 'Cada pedido se prepara a mano y se envía en un packaging especial pensado para ti.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _ValueCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.arenaLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
