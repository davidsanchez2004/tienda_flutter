import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';
import 'package:intl/intl.dart';

class AdminDiscountsScreen extends ConsumerStatefulWidget {
  const AdminDiscountsScreen({super.key});

  @override
  ConsumerState<AdminDiscountsScreen> createState() =>
      _AdminDiscountsScreenState();
}

class _AdminDiscountsScreenState extends ConsumerState<AdminDiscountsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Discount codes state
  List<dynamic> _codes = [];
  bool _codesLoading = true;

  // Auto coupon rules state
  List<Map<String, dynamic>> _rules = [];
  bool _rulesLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCodes();
    _loadRules();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Discount Codes ───────────────────────────────
  Future<void> _loadCodes() async {
    setState(() => _codesLoading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final codes = await repo.getDiscountCodes();
      if (mounted)
        setState(() {
          _codes = codes;
          _codesLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _codesLoading = false);
    }
  }

  Future<void> _deleteCode(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar código'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.deleteDiscountCode(id);
        _loadCodes();
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showCreateCodeForm() {
    final codeC = TextEditingController();
    final discountC = TextEditingController();
    String discountType = 'percentage';
    final minAmountC = TextEditingController();
    final maxUsesC = TextEditingController();
    DateTime? expiresAt;

    // Auto coupon fields
    bool isAutoCoupon = false;
    final thresholdC = TextEditingController();
    final daysC = TextEditingController(text: '30');
    final messageC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: AppColors.arenaLight))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nuevo Cupón',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Type selector
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.arenaPale,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setSheetState(() => isAutoCoupon = false),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !isAutoCoupon
                                      ? AppColors.arena
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Código Manual',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: !isAutoCoupon
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setSheetState(() => isAutoCoupon = true),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isAutoCoupon
                                      ? AppColors.arena
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Cupón Automático',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isAutoCoupon
                                        ? AppColors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!isAutoCoupon) ...[
                      // ── Manual discount code fields ──
                      TextField(
                          controller: codeC,
                          decoration: const InputDecoration(
                              labelText: 'Código',
                              border: OutlineInputBorder()),
                          textCapitalization: TextCapitalization.characters),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: TextField(
                                controller: discountC,
                                decoration: const InputDecoration(
                                    labelText: 'Valor descuento',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: discountType,
                            decoration: const InputDecoration(
                                labelText: 'Tipo',
                                border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(
                                  value: 'percentage',
                                  child: Text('Porcentaje %')),
                              DropdownMenuItem(
                                  value: 'fixed', child: Text('Fijo €')),
                            ],
                            onChanged: (v) =>
                                setSheetState(() => discountType = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: TextField(
                                controller: minAmountC,
                                decoration: const InputDecoration(
                                    labelText: 'Mínimo (€)',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                                controller: maxUsesC,
                                decoration: const InputDecoration(
                                    labelText: 'Usos máx.',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                      ]),
                      const SizedBox(height: 12),
                      ListTile(
                        title: Text(expiresAt != null
                            ? 'Expira: ${DateFormat('dd/MM/yyyy').format(expiresAt!)}'
                            : 'Fecha de expiración'),
                        trailing: const Icon(Icons.calendar_today),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side:
                                const BorderSide(color: AppColors.arenaLight)),
                        onTap: () async {
                          final date = await showDatePicker(
                              context: ctx,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)));
                          if (date != null)
                            setSheetState(() => expiresAt = date);
                        },
                      ),
                    ] else ...[
                      // ── Auto coupon fields ──
                      TextField(
                          controller: thresholdC,
                          decoration: const InputDecoration(
                              labelText: 'Umbral de gasto acumulado (€)',
                              border: OutlineInputBorder(),
                              helperText:
                                  'El cupón se genera al alcanzar este gasto'),
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: TextField(
                                controller: discountC,
                                decoration: const InputDecoration(
                                    labelText: 'Valor descuento',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: discountType,
                            decoration: const InputDecoration(
                                labelText: 'Tipo',
                                border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(
                                  value: 'percentage',
                                  child: Text('Porcentaje %')),
                              DropdownMenuItem(
                                  value: 'fixed', child: Text('Fijo €')),
                            ],
                            onChanged: (v) =>
                                setSheetState(() => discountType = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: TextField(
                                controller: minAmountC,
                                decoration: const InputDecoration(
                                    labelText: 'Compra mínima (€)',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                                controller: daysC,
                                decoration: const InputDecoration(
                                    labelText: 'Días de validez',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number)),
                      ]),
                      const SizedBox(height: 12),
                      TextField(
                          controller: messageC,
                          decoration: const InputDecoration(
                              labelText: 'Mensaje personalizado (opcional)',
                              border: OutlineInputBorder()),
                          maxLines: 2),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final repo = ref.read(adminRepositoryProvider);
                        if (!isAutoCoupon) {
                          await repo.createDiscountCode({
                            'code': codeC.text.toUpperCase(),
                            'discount_type': discountType,
                            'discount_value':
                                double.tryParse(discountC.text) ?? 0,
                            if (minAmountC.text.isNotEmpty)
                              'min_amount': double.tryParse(minAmountC.text),
                            if (maxUsesC.text.isNotEmpty)
                              'max_uses': int.tryParse(maxUsesC.text),
                            if (expiresAt != null)
                              'expires_at': expiresAt!.toIso8601String(),
                            'is_active': true,
                          });
                          _loadCodes();
                        } else {
                          await repo.createAutoCouponRule({
                            'spendThreshold':
                                double.tryParse(thresholdC.text) ?? 0,
                            'discountType': discountType,
                            'discountValue':
                                double.tryParse(discountC.text) ?? 0,
                            'minPurchase':
                                double.tryParse(minAmountC.text) ?? 0,
                            'validDays': int.tryParse(daysC.text) ?? 30,
                            'personalMessage': messageC.text,
                          });
                          _loadRules();
                        }
                        if (mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.arena,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(isAutoCoupon
                        ? 'Crear Regla Automática'
                        : 'Crear Código'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Auto Coupon Rules ────────────────────────────
  Future<void> _loadRules() async {
    setState(() => _rulesLoading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final rules = await repo.getAutoCouponRules();
      if (mounted)
        setState(() {
          _rules = rules;
          _rulesLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _rulesLoading = false);
    }
  }

  Future<void> _toggleRule(Map<String, dynamic> rule) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.toggleAutoCouponRule(rule['id'], !(rule['is_active'] ?? true));
      _loadRules();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteRule(Map<String, dynamic> rule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Regla'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.deleteAutoCouponRule(rule['id']);
        _loadRules();
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cupones y Descuentos'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.arena,
          indicatorColor: AppColors.arena,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Códigos', icon: Icon(Icons.local_offer, size: 18)),
            Tab(text: 'Automáticos', icon: Icon(Icons.auto_awesome, size: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCodeForm,
        backgroundColor: AppColors.arena,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Manual codes
          _codesLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.arena))
              : RefreshIndicator(
                  onRefresh: _loadCodes,
                  child: _codes.isEmpty
                      ? ListView(children: const [
                          SizedBox(height: 100),
                          Center(child: Text('No hay códigos de descuento')),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _codes.length,
                          itemBuilder: (ctx, i) {
                            final c = _codes[i] as Map<String, dynamic>;
                            final isActive = c['is_active'] == true;
                            final discountValue = c['discount_value'] is num
                                ? (c['discount_value'] as num).toDouble()
                                : 0.0;
                            final isPercentage =
                                c['discount_type'] == 'percentage';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.arenaPale
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.local_offer,
                                      color: isActive
                                          ? AppColors.arena
                                          : Colors.grey),
                                ),
                                title: Text(c['code'] ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary)),
                                subtitle: Text(
                                  '${isPercentage ? '${discountValue.toStringAsFixed(0)}%' : '${discountValue.toStringAsFixed(2)}€'} · Usos: ${c['times_used'] ?? 0}/${c['max_uses'] ?? '∞'}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () =>
                                      _deleteCode(c['id'].toString()),
                                ),
                              ),
                            );
                          },
                        ),
                ),

          // Tab 2: Auto coupon rules
          _rulesLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.arena))
              : RefreshIndicator(
                  onRefresh: _loadRules,
                  child: _rules.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 80),
                          const Icon(Icons.auto_awesome,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          const Center(
                              child: Text('No hay reglas automáticas')),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Crea reglas para enviar cupones automáticamente cuando los clientes alcancen cierto nivel de gasto.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rules.length,
                          itemBuilder: (ctx, i) {
                            final rule = _rules[i];
                            final isActive = rule['is_active'] ?? true;
                            final dt = rule['discount_type'] ?? 'percentage';
                            final dv = (rule['discount_value'] ?? 0).toDouble();
                            final threshold =
                                (rule['spend_threshold'] ?? 0).toDouble();
                            final minPurchase =
                                (rule['min_purchase'] ?? 0).toDouble();
                            final validDays = rule['valid_days'] ?? 30;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Gasto ≥ ${threshold.toStringAsFixed(0)}${AppConfig.currency} → '
                                            '${dt == 'percentage' ? '${dv.toStringAsFixed(0)}%' : '${dv.toStringAsFixed(2)}${AppConfig.currency}'} dto.',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15),
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
                                        _InfoChip(
                                            icon: Icons.shopping_cart,
                                            label:
                                                'Mín: ${minPurchase.toStringAsFixed(0)}${AppConfig.currency}'),
                                        _InfoChip(
                                            icon: Icons.calendar_today,
                                            label: '$validDays días'),
                                        if (!isActive)
                                          const _InfoChip(
                                              icon: Icons.pause_circle,
                                              label: 'Inactivo'),
                                      ],
                                    ),
                                    if (rule['personal_message'] != null &&
                                        rule['personal_message']
                                            .toString()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text('"${rule['personal_message']}"',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: AppColors.textSecondary)),
                                    ],
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: AppColors.error, size: 20),
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
        ],
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
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
