import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/data/repositories/order_repository.dart';
import 'package:intl/intl.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final _emailCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_emailCtrl.text.isEmpty || _orderCtrl.text.isEmpty) {
      setState(() => _error = 'Completa ambos campos');
      return;
    }
    setState(() { _isLoading = true; _error = null; _result = null; });

    try {
      final repo = ref.read(orderRepositoryProvider);
      final result = await repo.trackOrder(
        email: _emailCtrl.text.trim(),
        orderId: _orderCtrl.text.trim(),
      );
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rastrear Pedido')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Introduce tu email y número de pedido para rastrear el estado de tu envío.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _orderCtrl,
            decoration: const InputDecoration(
              labelText: 'Número de pedido',
              prefixIcon: Icon(Icons.receipt_outlined),
              hintText: 'Ej: AB12CD34',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _search,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Buscar Pedido'),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ),
          ],

          if (_result != null) ...[
            const SizedBox(height: 24),
            _buildResult(),
          ],
        ],
      ),
    );
  }

  Widget _buildResult() {
    final order = _result!['order'] ?? _result!;
    final status = order['status'] ?? 'unknown';
    final trackingNumber = order['tracking_number'];
    final carrier = order['carrier'];
    final total = (order['total'] ?? 0).toDouble();
    final createdAt = order['created_at'];

    String dateStr = '';
    if (createdAt != null) {
      dateStr = DateFormat('dd/MM/yyyy').format(DateTime.parse(createdAt));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.arenaLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información del pedido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _InfoLine('Estado', _statusLabel(status)),
          _InfoLine('Fecha', dateStr),
          _InfoLine('Total', '${total.toStringAsFixed(2)}${AppConfig.currency}'),
          if (trackingNumber != null) _InfoLine('Nº Seguimiento', trackingNumber),
          if (carrier != null) _InfoLine('Transportista', carrier),
          const SizedBox(height: 16),

          // Status timeline
          _StatusTimeline(currentStatus: status),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    const labels = {
      'pending': 'Pendiente',
      'paid': 'Pagado',
      'shipped': 'Enviado',
      'delivered': 'Entregado',
      'cancelled': 'Cancelado',
    };
    return labels[status] ?? status;
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _InfoLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String currentStatus;
  const _StatusTimeline({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = ['pending', 'paid', 'shipped', 'delivered'];
    final labels = ['Pendiente', 'Pagado', 'Enviado', 'Entregado'];
    final currentIdx = steps.indexOf(currentStatus);

    if (currentStatus == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error),
            SizedBox(width: 8),
            Text('Pedido cancelado', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(steps.length, (i) {
        final isCompleted = i <= currentIdx;
        final isCurrent = i == currentIdx;
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.arena : AppColors.arenaLight,
                    border: isCurrent ? Border.all(color: AppColors.gold, width: 2) : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: i < currentIdx ? AppColors.arena : AppColors.arenaLight,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              labels[i],
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
