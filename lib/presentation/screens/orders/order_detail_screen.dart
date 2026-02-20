import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/presentation/providers/order_provider.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';
import 'package:by_arena/data/repositories/order_repository.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  Future<void> _downloadInvoice(BuildContext context, WidgetRef ref, String orderId) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descargando factura...')),
      );
      final repo = ref.read(orderRepositoryProvider);
      final bytes = await repo.downloadOrderInvoice(orderId);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/factura_$orderId.pdf');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar factura: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Pedido')),
      body: orderAsync.when(
        data: (order) {
          final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order.createdAt));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Order header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.arenaLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pedido #${order.orderNumber}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.arenaPale,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(order.statusLabel,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Fecha: $date', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Items
              const Text('Productos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...order.items.map((item) => Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.arenaLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName ?? 'Producto',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text('x${item.quantity} · ${item.price.toStringAsFixed(2)}${AppConfig.currency}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    Text('${item.total.toStringAsFixed(2)}${AppConfig.currency}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )),

              const SizedBox(height: 16),

              // Totals
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.arenaPale,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _TotalRow('Subtotal', order.subtotal),
                    _TotalRow('Envío', order.shippingCost),
                    const Divider(),
                    _TotalRow('Total', order.total, bold: true),
                  ],
                ),
              ),

              // Tracking info
              if (order.trackingNumber != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.arenaLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Seguimiento', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Nº: ${order.trackingNumber}'),
                      if (order.carrier != null) Text('Transportista: ${order.carrier}'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Download invoice button
              if (order.paymentStatus == 'paid' || order.status == 'paid' || order.status == 'shipped' || order.status == 'delivered')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadInvoice(context, ref, order.id),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Descargar Factura'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),

              // Actions
              if (order.status == 'delivered')
                OutlinedButton.icon(
                  onPressed: () => context.push('/devolucion/${order.id}'),
                  icon: const Icon(Icons.replay),
                  label: const Text('Solicitar Devolución'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorDisplay(
          message: 'Error al cargar pedido',
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;
  const _TotalRow(this.label, this.amount, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text('${amount.toStringAsFixed(2)}${AppConfig.currency}',
              style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
