import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/presentation/providers/order_provider.dart';
import 'package:by_arena/presentation/providers/auth_provider.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';
import 'package:by_arena/data/repositories/order_repository.dart';
import 'package:by_arena/data/repositories/return_repository.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (auth.status != AuthStatus.authenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Pedidos')),
        body: _GuestOrderLookup(),
      );
    }

    final orders = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos')),
      body: orders.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 48, color: AppColors.arenaLight),
                  SizedBox(height: 16),
                  Text('No tienes pedidos aún'),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myOrdersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final order = list[index];
                final date = DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(order.createdAt));
                return GestureDetector(
                  onTap: () => context.push('/pedido/${order.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                            Text('#${order.orderNumber}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            _StatusBadge(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(date,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          '${order.total.toStringAsFixed(2)}${AppConfig.currency}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const ShimmerList(),
        error: (e, _) => ErrorDisplay(
          message: 'Error al cargar pedidos',
          onRetry: () => ref.invalidate(myOrdersProvider),
        ),
      ),
    );
  }
}

// ── Guest order lookup form ──
class _GuestOrderLookup extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GuestOrderLookup> createState() => _GuestOrderLookupState();
}

class _GuestOrderLookupState extends ConsumerState<_GuestOrderLookup> {
  final _emailCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchOrder() async {
    final email = _emailCtrl.text.trim();
    final orderId = _orderCtrl.text.trim();
    if (email.isEmpty || orderId.isEmpty) {
      setState(() => _error = 'Completa ambos campos');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(orderRepositoryProvider);
      final result = await repo.trackOrder(email: email, orderId: orderId);
      final order = result['order'];
      if (order != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _GuestOrderDetailScreen(
              order: order as Map<String, dynamic>,
              guestEmail: email,
            ),
          ),
        );
      } else {
        setState(() => _error = 'No se encontró el pedido');
      }
    } catch (e) {
      setState(() => _error = 'No se encontró el pedido. Verifica los datos.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.arenaPale,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.search_rounded,
                  size: 40, color: AppColors.arena),
              const SizedBox(height: 12),
              const Text(
                'Buscar tu pedido',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Introduce el email usado en la compra y tu número de pedido para ver el estado y solicitar devoluciones.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailCtrl,
          decoration: const InputDecoration(
            labelText: 'Email de la compra',
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
            hintText: 'Ej: ab12cd34',
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _searchOrder,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Buscar Pedido'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
        const SizedBox(height: 32),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  Text('O', style: TextStyle(color: AppColors.textSecondary)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.push('/login'),
          icon: const Icon(Icons.login),
          label: const Text('Iniciar sesión para ver todos tus pedidos'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

// ── Guest order detail screen ──
class _GuestOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String guestEmail;

  const _GuestOrderDetailScreen({
    required this.order,
    required this.guestEmail,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'unknown';
    final total = (order['total'] ?? 0).toDouble();
    final subtotal = (order['subtotal'] ?? 0).toDouble();
    final shippingCost = (order['shipping_cost'] ?? 0).toDouble();
    final trackingNumber = order['tracking_number'];
    final carrier = order['carrier'];
    final items = (order['items'] as List?) ?? [];
    final createdAt = order['created_at'];
    final orderId = order['id'] ?? '';

    String dateStr = '';
    if (createdAt != null) {
      try {
        dateStr = DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(createdAt.toString()));
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Pedido')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
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
                    Expanded(
                      child: Text(
                        'Pedido #${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    _StatusBadge(status: status),
                  ],
                ),
                if (dateStr.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Fecha: $dateStr',
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
                Text('Email: $guestEmail',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Items
          const Text('Productos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...items.map((item) {
            final name = item['name'] ?? 'Producto';
            final qty = item['quantity'] ?? 1;
            final price = (item['price'] ?? 0).toDouble();
            return Container(
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
                        Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                            'x$qty · ${price.toStringAsFixed(2)}${AppConfig.currency}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Text(
                      '${(price * qty).toStringAsFixed(2)}${AppConfig.currency}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),

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
                _TotalRow('Subtotal', subtotal),
                _TotalRow('Envío', shippingCost),
                const Divider(),
                _TotalRow('Total', total, bold: true),
              ],
            ),
          ),

          // Tracking
          if (trackingNumber != null) ...[
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
                  const Text('Seguimiento',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Nº: $trackingNumber'),
                  if (carrier != null) Text('Transportista: $carrier'),
                ],
              ),
            ),
          ],

          // Status timeline
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
                const Text('Estado del envío',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _StatusTimeline(currentStatus: status),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Return button - only for delivered/shipped orders
          if (status == 'delivered' || status == 'shipped')
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _GuestReturnScreen(
                      order: order,
                      guestEmail: guestEmail,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.replay),
              label: const Text('Solicitar Devolución'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Guest return screen ──
class _GuestReturnScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  final String guestEmail;

  const _GuestReturnScreen({
    required this.order,
    required this.guestEmail,
  });

  @override
  ConsumerState<_GuestReturnScreen> createState() => _GuestReturnScreenState();
}

class _GuestReturnScreenState extends ConsumerState<_GuestReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  String _reason = 'not_liked';
  final Set<int> _selectedItems = {};
  bool _isLoading = false;
  bool _success = false;
  String? _errorMessage;
  String? _returnNumber;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      setState(() => _errorMessage = 'Selecciona al menos un producto');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allItems = (widget.order['items'] as List?) ?? [];
      final selectedOrderItems =
          _selectedItems.map((i) => allItems[i]).toList();

      final items = selectedOrderItems.map((item) {
        return {
          'orderItemId': item['id'],
          'productId': item['product_id'],
          'productName': item['name'] ?? 'Producto',
          'quantity': item['quantity'],
          'price': item['price'],
          'reason': _reason,
        };
      }).toList();

      final repo = ref.read(returnRepositoryProvider);
      final result = await repo.createReturnRequest(
        orderId: widget.order['id'],
        reason: _reason,
        description: _descriptionCtrl.text,
        guestEmail: widget.guestEmail,
        items: items,
      );

      setState(() {
        _success = true;
        _returnNumber = result['return']?['return_number'];
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = (widget.order['items'] as List?) ?? [];

    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Devolución')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    size: 64, color: AppColors.success),
                const SizedBox(height: 16),
                const Text('Solicitud enviada',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (_returnNumber != null)
                  Text('Nº de devolución: $_returnNumber',
                      style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text(
                  'Revisaremos tu solicitud y te contactaremos por email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Volver al inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Devolución')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
                'Pedido #${(widget.order['id'] ?? '').toString().substring(0, 8).toUpperCase()}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('Selecciona los artículos a devolver:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...List.generate(items.length, (index) {
              final item = items[index];
              return CheckboxListTile(
                title: Text(item['name'] ?? 'Producto'),
                subtitle: Text(
                    'x${item['quantity']} · ${(item['price'] ?? 0).toDouble().toStringAsFixed(2)}€'),
                value: _selectedItems.contains(index),
                activeColor: AppColors.arena,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedItems.add(index);
                    } else {
                      _selectedItems.remove(index);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 16),
            const Text('Motivo:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _reason,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(
                    value: 'not_liked', child: Text('No me gusta')),
                DropdownMenuItem(value: 'defective', child: Text('Defectuoso')),
                DropdownMenuItem(
                    value: 'error', child: Text('Error en el pedido')),
                DropdownMenuItem(value: 'other', child: Text('Otro')),
              ],
              onChanged: (v) => setState(() => _reason = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Describe el problema',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Describe el motivo' : null,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!,
                  style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Enviar Solicitud'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ──
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'pending':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        label = 'Pendiente';
        break;
      case 'paid':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        label = 'Pagado';
        break;
      case 'shipped':
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade700;
        label = 'Enviado';
        break;
      case 'delivered':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        label = 'Entregado';
        break;
      case 'cancelled':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        label = 'Cancelado';
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade700;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style:
              TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
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
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text('${amount.toStringAsFixed(2)}${AppConfig.currency}',
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
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
            Text('Pedido cancelado',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
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
                    border: isCurrent
                        ? Border.all(color: AppColors.gold, width: 2)
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color:
                        i < currentIdx ? AppColors.arena : AppColors.arenaLight,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              labels[i],
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isCompleted
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
