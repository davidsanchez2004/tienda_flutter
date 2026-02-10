import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/presentation/providers/cart_provider.dart';
import 'package:by_arena/presentation/providers/auth_provider.dart';
import 'package:by_arena/data/repositories/checkout_repository.dart';
import 'package:by_arena/data/repositories/product_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  String _shippingMethod = 'delivery';
  bool _isLoading = false;
  String? _errorMessage;
  double _discountAmount = 0;
  String? _appliedDiscount;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    if (auth.user != null) {
      _nameCtrl.text = auth.user!.fullName;
      _emailCtrl.text = auth.user!.email;
      _phoneCtrl.text = auth.user!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateDiscount() async {
    if (_discountCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(checkoutRepositoryProvider);
      final subtotal = ref.read(cartSubtotalProvider);
      final result = await repo.validateDiscount(
        code: _discountCtrl.text,
        email: _emailCtrl.text,
        cartTotal: subtotal,
      );
      if (result['valid'] == true) {
        setState(() {
          _discountAmount = (result['discount_amount'] ?? 0).toDouble();
          _appliedDiscount = _discountCtrl.text;
          _errorMessage = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código aplicado correctamente'), backgroundColor: AppColors.success),
          );
        }
      } else {
        setState(() => _errorMessage = result['error'] ?? 'Código no válido');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate stock first
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final cartItems = ref.read(cartProvider);
      final productRepo = ref.read(productRepositoryProvider);

      final stockItems = cartItems.map((i) => {
        'product_id': i.productId,
        'quantity': i.quantity,
      }).toList();

      final stockResult = await productRepo.validateStock(stockItems);
      if (stockResult['valid'] != true) {
        final issues = (stockResult['items'] as List?)
            ?.where((i) => i['available'] != true)
            .map((i) => i['name'] ?? 'Producto')
            .join(', ');
        setState(() => _errorMessage = 'Stock insuficiente: $issues');
        return;
      }

      // Create checkout session
      final checkoutRepo = ref.read(checkoutRepositoryProvider);
      final subtotal = ref.read(cartSubtotalProvider);
      final shipping = ref.read(cartShippingProvider);
      final total = subtotal + shipping - _discountAmount;
      final auth = ref.read(authProvider);

      final result = await checkoutRepo.createSession(
        items: ref.read(cartProvider.notifier).toApiItems(),
        customer: {
          'name': _nameCtrl.text,
          'email': _emailCtrl.text,
          'phone': _phoneCtrl.text,
          'address': _addressCtrl.text,
          'city': _cityCtrl.text,
          'postalCode': _postalCtrl.text,
        },
        shippingMethod: _shippingMethod,
        shippingCost: shipping,
        subtotal: subtotal,
        total: total,
        discountCode: _appliedDiscount,
        userId: auth.user?.id,
      );

      // Open Stripe checkout URL
      final url = result['url'] ?? result['checkout_url'];
      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          ref.read(cartProvider.notifier).clear();
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final shipping = ref.watch(cartShippingProvider);
    final total = subtotal + shipping - _discountAmount;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer info
            const Text('Datos de contacto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),

            const SizedBox(height: 24),

            // Shipping method
            const Text('Método de envío', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: Text('Envío a domicilio (${shipping > 0 ? "${shipping.toStringAsFixed(2)}${AppConfig.currency}" : "GRATIS"})'),
              value: 'delivery',
              groupValue: _shippingMethod,
              activeColor: AppColors.arena,
              onChanged: (v) => setState(() => _shippingMethod = v!),
            ),
            RadioListTile<String>(
              title: const Text('Recogida en tienda (Gratis)'),
              value: 'pickup',
              groupValue: _shippingMethod,
              activeColor: AppColors.arena,
              onChanged: (v) => setState(() => _shippingMethod = v!),
            ),

            if (_shippingMethod == 'delivery') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (v) => _shippingMethod == 'delivery' && v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                      validator: (v) => _shippingMethod == 'delivery' && v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _postalCtrl,
                      decoration: const InputDecoration(labelText: 'Código Postal'),
                      keyboardType: TextInputType.number,
                      validator: (v) => _shippingMethod == 'delivery' && v!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Discount code
            const Text('Código de descuento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _discountCtrl,
                    decoration: const InputDecoration(hintText: 'Código'),
                    enabled: _appliedDiscount == null,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _appliedDiscount == null && !_isLoading ? _validateDiscount : null,
                  child: Text(_appliedDiscount != null ? 'Aplicado ✓' : 'Aplicar'),
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
            ],

            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.arenaPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _Row('Subtotal', '${subtotal.toStringAsFixed(2)}${AppConfig.currency}'),
                  if (_discountAmount > 0)
                    _Row('Descuento', '-${_discountAmount.toStringAsFixed(2)}${AppConfig.currency}',
                        color: AppColors.success),
                  _Row('Envío', shipping == 0
                      ? 'GRATIS'
                      : '${shipping.toStringAsFixed(2)}${AppConfig.currency}'),
                  const Divider(),
                  _Row('Total', '${total.toStringAsFixed(2)}${AppConfig.currency}', bold: true),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processCheckout,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Pagar con Stripe', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;
  const _Row(this.label, this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400, fontSize: bold ? 16 : 14)),
          Text(value, style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontSize: bold ? 16 : 14,
            color: color,
          )),
        ],
      ),
    );
  }
}
