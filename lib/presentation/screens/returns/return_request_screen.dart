import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/return_repository.dart';
import 'package:by_arena/presentation/providers/order_provider.dart';
import 'package:by_arena/presentation/widgets/shared_widgets.dart';

class ReturnRequestScreen extends ConsumerStatefulWidget {
  final String orderId;
  const ReturnRequestScreen({super.key, required this.orderId});

  @override
  ConsumerState<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends ConsumerState<ReturnRequestScreen> {
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

    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final orderAsync = ref.read(orderDetailProvider(widget.orderId));
      final order = orderAsync.value!;

      final selectedOrderItems = _selectedItems
          .map((i) => order.items[i])
          .toList();

      final items = selectedOrderItems.map((item) => {
        'orderItemId': item.id,
        'productId': item.productId,
        'productName': item.productName ?? 'Producto',
        'quantity': item.quantity,
        'price': item.price,
        'reason': _reason,
      }).toList();

      final repo = ref.read(returnRepositoryProvider);
      final result = await repo.createReturnRequest(
        orderId: widget.orderId,
        reason: _reason,
        description: _descriptionCtrl.text,
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
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    if (_success) {
      return Scaffold(
        appBar: AppBar(title: const Text('Devolución')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 64, color: AppColors.success),
                const SizedBox(height: 16),
                const Text('Solicitud enviada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Devolución')),
      body: orderAsync.when(
        data: (order) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Pedido #${order.orderNumber}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              // Select items
              const Text('Selecciona los artículos a devolver:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...List.generate(order.items.length, (index) {
                final item = order.items[index];
                return CheckboxListTile(
                  title: Text(item.productName ?? 'Producto'),
                  subtitle: Text('x${item.quantity} · ${item.price.toStringAsFixed(2)}€'),
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

              // Reason
              const Text('Motivo:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _reason,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: 'not_liked', child: Text('No me gusta')),
                  DropdownMenuItem(value: 'defective', child: Text('Defectuoso')),
                  DropdownMenuItem(value: 'error', child: Text('Error en el pedido')),
                  DropdownMenuItem(value: 'other', child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _reason = v!),
              ),
              const SizedBox(height: 16),

              // Description
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
                Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enviar Solicitud'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorDisplay(
          message: 'Error al cargar pedido',
          onRetry: () => ref.invalidate(orderDetailProvider(widget.orderId)),
        ),
      ),
    );
  }
}
