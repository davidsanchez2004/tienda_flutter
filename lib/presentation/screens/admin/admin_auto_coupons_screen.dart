import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';

class AdminAutoCouponsScreen extends ConsumerStatefulWidget {
  const AdminAutoCouponsScreen({super.key});

  @override
  ConsumerState<AdminAutoCouponsScreen> createState() => _AdminAutoCouponsScreenState();
}

class _AdminAutoCouponsScreenState extends ConsumerState<AdminAutoCouponsScreen> {
  List<Map<String, dynamic>> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final rules = await repo.getAutoCouponRules();
      if (mounted) setState(() { _rules = rules; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final thresholdCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final daysCtrl = TextEditingController(text: '30');
    final minPurchaseCtrl = TextEditingController(text: '0');
    final messageCtrl = TextEditingController();
    String discountType = 'percentage';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva Regla de Cupón'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: thresholdCtrl,
                  decoration: const InputDecoration(labelText: 'Umbral de gasto (€)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'percentage', label: Text('%')),
                    ButtonSegment(value: 'fixed', label: Text('€')),
                  ],
                  selected: {discountType},
                  onSelectionChanged: (s) => setDialogState(() => discountType = s.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueCtrl,
                  decoration: InputDecoration(
                    labelText: 'Valor del descuento ${discountType == 'percentage' ? '(%)' : '(€)'}',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: minPurchaseCtrl,
                  decoration: const InputDecoration(labelText: 'Compra mínima (€)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: daysCtrl,
                  decoration: const InputDecoration(labelText: 'Días de validez'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageCtrl,
                  decoration: const InputDecoration(labelText: 'Mensaje personalizado (opcional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Crear')),
          ],
        ),
      ),
    );

    if (result == true && thresholdCtrl.text.isNotEmpty && valueCtrl.text.isNotEmpty) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.createAutoCouponRule({
          'spendThreshold': double.tryParse(thresholdCtrl.text) ?? 0,
          'discountType': discountType,
          'discountValue': double.tryParse(valueCtrl.text) ?? 0,
          'minPurchase': double.tryParse(minPurchaseCtrl.text) ?? 0,
          'validDays': int.tryParse(daysCtrl.text) ?? 30,
          'personalMessage': messageCtrl.text,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Regla creada correctamente')),
          );
        }
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
    thresholdCtrl.dispose();
    valueCtrl.dispose();
    daysCtrl.dispose();
    minPurchaseCtrl.dispose();
    messageCtrl.dispose();
  }

  Future<void> _toggleRule(Map<String, dynamic> rule) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.toggleAutoCouponRule(rule['id'], !(rule['is_active'] ?? true));
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteRule(Map<String, dynamic> rule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Regla'),
        content: const Text('¿Estás seguro de que deseas eliminar esta regla?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.deleteAutoCouponRule(rule['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Regla eliminada')),
          );
        }
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupones Automáticos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.arena,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _load,
              child: _rules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          const Text('No hay reglas de cupones automáticos'),
                          const SizedBox(height: 8),
                          const Text(
                            'Crea reglas para enviar cupones automáticamente\ncuando los clientes alcancen cierto nivel de gasto.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _rules.length,
                      itemBuilder: (ctx, i) {
                        final rule = _rules[i];
                        final isActive = rule['is_active'] ?? true;
                        final discountType = rule['discount_type'] ?? 'percentage';
                        final discountValue = (rule['discount_value'] ?? 0).toDouble();
                        final threshold = (rule['spend_threshold'] ?? 0).toDouble();
                        final minPurchase = (rule['min_purchase'] ?? 0).toDouble();
                        final validDays = rule['valid_days'] ?? 30;

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
                                    Expanded(
                                      child: Text(
                                        'Gasto ≥ ${threshold.toStringAsFixed(0)}${AppConfig.currency} → '
                                        '${discountType == 'percentage' ? '${discountValue.toStringAsFixed(0)}%' : '${discountValue.toStringAsFixed(2)}${AppConfig.currency}'} dto.',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                      ),
                                    ),
                                    Switch(
                                      value: isActive,
                                      onChanged: (_) => _toggleRule(rule),
                                      activeColor: AppColors.arena,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  children: [
                                    _InfoChip(icon: Icons.shopping_cart, label: 'Mín: ${minPurchase.toStringAsFixed(0)}${AppConfig.currency}'),
                                    _InfoChip(icon: Icons.calendar_today, label: '$validDays días'),
                                    if (!isActive)
                                      const _InfoChip(icon: Icons.pause_circle, label: 'Inactivo'),
                                  ],
                                ),
                                if (rule['personal_message'] != null && rule['personal_message'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '"${rule['personal_message']}"',
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                    onPressed: () => _deleteRule(rule),
                                    tooltip: 'Eliminar regla',
                                  ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
