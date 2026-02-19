import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';
import 'package:intl/intl.dart';

class AdminDiscountsScreen extends ConsumerStatefulWidget {
  const AdminDiscountsScreen({super.key});

  @override
  ConsumerState<AdminDiscountsScreen> createState() => _AdminDiscountsScreenState();
}

class _AdminDiscountsScreenState extends ConsumerState<AdminDiscountsScreen> {
  List<dynamic> _codes = [];
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
      final codes = await repo.getDiscountCodes();
      if (mounted) setState(() { _codes = codes; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar código'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.deleteDiscountCode(id);
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showCreateForm() {
    final codeC = TextEditingController();
    final discountC = TextEditingController();
    String discountType = 'percentage';
    final minAmountC = TextEditingController();
    final maxUsesC = TextEditingController();
    DateTime? expiresAt;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.arenaLight))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nuevo Código de Descuento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(controller: codeC, decoration: const InputDecoration(labelText: 'Código', border: OutlineInputBorder()), textCapitalization: TextCapitalization.characters),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextField(controller: discountC, decoration: const InputDecoration(labelText: 'Valor descuento', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: discountType,
                          decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'percentage', child: Text('Porcentaje %')),
                            DropdownMenuItem(value: 'fixed', child: Text('Fijo €')),
                          ],
                          onChanged: (v) => setSheetState(() => discountType = v!),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextField(controller: minAmountC, decoration: const InputDecoration(labelText: 'Mínimo (€)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: maxUsesC, decoration: const InputDecoration(labelText: 'Usos máx.', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    ]),
                    const SizedBox(height: 12),
                    ListTile(
                      title: Text(expiresAt != null ? 'Expira: ${DateFormat('dd/MM/yyyy').format(expiresAt!)}' : 'Fecha de expiración'),
                      trailing: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.arenaLight)),
                      onTap: () async {
                        final date = await showDatePicker(context: ctx, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                        if (date != null) setSheetState(() => expiresAt = date);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final data = {
                        'code': codeC.text.toUpperCase(),
                        'discount_type': discountType,
                        'discount_value': double.tryParse(discountC.text) ?? 0,
                        if (minAmountC.text.isNotEmpty) 'min_amount': double.tryParse(minAmountC.text),
                        if (maxUsesC.text.isNotEmpty) 'max_uses': int.tryParse(maxUsesC.text),
                        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
                        'is_active': true,
                      };
                      try {
                        final repo = ref.read(adminRepositoryProvider);
                        await repo.createDiscountCode(data);
                        if (mounted) Navigator.pop(ctx);
                        _load();
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.arena, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Crear Código'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Códigos de Descuento')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateForm,
        backgroundColor: AppColors.arena,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _load,
              child: _codes.isEmpty
                  ? const Center(child: Text('No hay códigos de descuento'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _codes.length,
                      itemBuilder: (ctx, i) {
                        final c = _codes[i] as Map<String, dynamic>;
                        final isActive = c['is_active'] == true;
                        final discountValue = c['discount_value'] is num ? (c['discount_value'] as num).toDouble() : 0.0;
                        final isPercentage = c['discount_type'] == 'percentage';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.arenaPale : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.local_offer, color: isActive ? AppColors.arena : Colors.grey),
                            ),
                            title: Text(c['code'] ?? '', style: TextStyle(fontWeight: FontWeight.w700, color: isActive ? AppColors.textPrimary : AppColors.textSecondary)),
                            subtitle: Text(
                              '${isPercentage ? '${discountValue.toStringAsFixed(0)}%' : '${discountValue.toStringAsFixed(2)}€'} • Usos: ${c['times_used'] ?? 0}/${c['max_uses'] ?? '∞'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _delete(c['id'].toString()),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
