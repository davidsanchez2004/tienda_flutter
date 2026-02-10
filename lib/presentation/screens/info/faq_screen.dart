import 'package:flutter/material.dart';
import 'package:by_arena/core/theme/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preguntas Frecuentes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _FaqSection(title: 'Pedidos', items: [
            _FaqItem(
              question: '¿Cuánto tarda en llegar mi pedido?',
              answer: 'Los pedidos se procesan en 24-48h laborables. '
                  'El envío estándar tarda entre 3-5 días laborables en España peninsular.',
            ),
            _FaqItem(
              question: '¿Puedo hacer seguimiento de mi pedido?',
              answer: 'Sí, desde la sección "Rastrear Pedido" puedes consultar el estado '
                  'de tu envío con tu email y número de pedido.',
            ),
            _FaqItem(
              question: '¿Puedo modificar mi pedido una vez realizado?',
              answer: 'Si el pedido aún no ha sido enviado, contáctanos y haremos lo posible '
                  'por modificarlo. Una vez enviado no es posible.',
            ),
          ]),
          _FaqSection(title: 'Envíos', items: [
            _FaqItem(
              question: '¿Cuánto cuesta el envío?',
              answer: 'El envío estándar cuesta 4,95€. ¡Envío gratis en pedidos superiores a 50€!',
            ),
            _FaqItem(
              question: '¿Realizáis envíos internacionales?',
              answer: 'Actualmente solo realizamos envíos a España peninsular e islas Baleares.',
            ),
          ]),
          _FaqSection(title: 'Devoluciones', items: [
            _FaqItem(
              question: '¿Cuál es la política de devoluciones?',
              answer: 'Dispones de 14 días naturales desde la recepción para devolver cualquier '
                  'artículo en su estado original. Los gastos de devolución corren a cargo del cliente.',
            ),
            _FaqItem(
              question: '¿Cómo solicito una devolución?',
              answer: 'Desde "Mis Pedidos", accede al detalle del pedido y pulsa '
                  '"Solicitar Devolución". Recibirás las instrucciones por email.',
            ),
          ]),
          _FaqSection(title: 'Pagos', items: [
            _FaqItem(
              question: '¿Qué métodos de pago aceptáis?',
              answer: 'Aceptamos tarjeta de crédito/débito (Visa, Mastercard, Amex) a través de Stripe, '
                  'el procesador de pagos más seguro del mundo.',
            ),
            _FaqItem(
              question: '¿Es seguro pagar en BY ARENA?',
              answer: 'Totalmente. Utilizamos Stripe como pasarela de pago, que cumple con '
                  'los más altos estándares de seguridad PCI DSS Level 1.',
            ),
          ]),
          _FaqSection(title: 'Cuenta', items: [
            _FaqItem(
              question: '¿Necesito una cuenta para comprar?',
              answer: 'No es obligatorio, puedes comprar como invitado. Sin embargo, con una '
                  'cuenta podrás hacer seguimiento de pedidos, guardar favoritos y más.',
            ),
          ]),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  final String title;
  final List<_FaqItem> items;
  const _FaqSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        ...items,
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        iconColor: AppColors.arena,
        children: [Text(answer, style: const TextStyle(color: AppColors.textSecondary, height: 1.5))],
      ),
    );
  }
}
