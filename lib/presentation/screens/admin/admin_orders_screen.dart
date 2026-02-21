import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = ref.read(adminRepositoryProvider);
      final orders = await repo.getAllOrders();
      if (mounted) setState(() { _orders = orders; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'shipped': return Colors.blue;
      case 'processing': return AppColors.arena;
      case 'cancelled': return Colors.red;
      default: return AppColors.textSecondary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'completed': return 'Completado';
      case 'shipped': return 'Enviado';
      case 'processing': return 'Procesando';
      case 'cancelled': return 'Cancelado';
      case 'pending': return 'Pendiente';
      default: return status ?? 'Desconocido';
    }
  }

  Future<void> _showUpdateStatusDialog(Map<String, dynamic> order) async {
    const statuses = ['pending', 'processing', 'shipped', 'completed', 'cancelled'];
    String selectedStatus = order['status'] ?? 'pending';

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Pedido #${order['id'].toString().substring(0, 8)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Actualizar estado:'),
              const SizedBox(height: 12),
              ...statuses.map((s) => RadioListTile<String>(
                value: s,
                groupValue: selectedStatus,
                title: Text(_statusLabel(s)),
                activeColor: AppColors.arena,
                onChanged: (v) => setDialogState(() => selectedStatus = v!),
              )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selectedStatus),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.arena),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result != order['status']) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.updateOrderStatus(order['id'], {'status': result});
        _loadOrders();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _showTrackingDialog(Map<String, dynamic> order) async {
    final controller = TextEditingController(text: order['tracking_number'] ?? '');
    final carrierController = TextEditingController(text: order['tracking_carrier'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Actualizar Tracking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: carrierController, decoration: const InputDecoration(labelText: 'Transportista')),
            const SizedBox(height: 12),
            TextField(controller: controller, decoration: const InputDecoration(labelText: 'Número de seguimiento')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.arena),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.updateTracking(order['id'], controller.text, carrierController.text);
        _loadOrders();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tracking actualizado')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Pedidos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Error: $_error'),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _loadOrders, child: const Text('Reintentar')),
                ]))
              : _orders.isEmpty
                  ? const Center(child: Text('No hay pedidos'))
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (ctx, i) {
                          final order = _orders[i] as Map<String, dynamic>;
                          final total = (order['total'] is num) ? (order['total'] as num).toDouble() : 0.0;
                          final createdAt = DateTime.tryParse(order['created_at'] ?? '');
                          final dateStr = createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt) : '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text('#${order['id'].toString().substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(order['status']).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(_statusLabel(order['status']), style: TextStyle(color: _statusColor(order['status']), fontWeight: FontWeight.w600, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('${order['customer_name'] ?? order['guest_name'] ?? 'Sin nombre'}', style: const TextStyle(fontSize: 14)),
                                  Text(dateStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Text('${total.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.arena)),
                                  if (order['tracking_number'] != null && (order['tracking_number'] as String).isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('Tracking: ${order['tracking_number']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: const Text('Estado'),
                                          onPressed: () => _showUpdateStatusDialog(order),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.local_shipping, size: 16),
                                          label: const Text('Tracking'),
                                          onPressed: () => _showTrackingDialog(order),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
