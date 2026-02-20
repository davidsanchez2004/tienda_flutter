import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';
import 'package:by_arena/domain/models/invoice.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class AdminInvoicesScreen extends ConsumerStatefulWidget {
  const AdminInvoicesScreen({super.key});

  @override
  ConsumerState<AdminInvoicesScreen> createState() => _AdminInvoicesScreenState();
}

class _AdminInvoicesScreenState extends ConsumerState<AdminInvoicesScreen> {
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String _filter = 'all'; // all | purchase | return
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final type = _filter == 'all' ? null : _filter;
      final invoices = await repo.getInvoices(type: type);
      if (mounted) setState(() { _invoices = invoices; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar facturas: $e')),
        );
      }
    }
  }

  List<Invoice> get _filteredInvoices {
    if (_searchQuery.isEmpty) return _invoices;
    final q = _searchQuery.toLowerCase();
    return _invoices.where((inv) =>
      inv.invoiceNumber.toLowerCase().contains(q) ||
      (inv.customerName?.toLowerCase().contains(q) ?? false) ||
      (inv.customerEmail?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  double get _totalPurchases => _invoices
      .where((i) => i.isPurchase)
      .fold(0.0, (sum, i) => sum + i.amount);

  double get _totalReturns => _invoices
      .where((i) => i.isReturn)
      .fold(0.0, (sum, i) => sum + i.amount.abs());

  Future<void> _downloadInvoice(Invoice invoice) async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      final bytes = await repo.downloadInvoicePdf(invoice.id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${invoice.invoiceNumber}.pdf');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar: $e')),
        );
      }
    }
  }

  Future<void> _showGenerateDialog() async {
    String type = 'purchase';
    final idCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Generar Factura'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'purchase', label: Text('Compra')),
                  ButtonSegment(value: 'return', label: Text('Devolución')),
                ],
                selected: {type},
                onSelectionChanged: (s) => setDialogState(() => type = s.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: idCtrl,
                decoration: InputDecoration(
                  labelText: type == 'purchase' ? 'ID del Pedido' : 'ID de la Devolución',
                  hintText: 'UUID...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Generar')),
          ],
        ),
      ),
    );

    if (result == true && idCtrl.text.isNotEmpty) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.generateInvoice(
          type: type,
          orderId: type == 'purchase' ? idCtrl.text.trim() : null,
          returnId: type == 'return' ? idCtrl.text.trim() : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Factura generada correctamente')),
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
    idCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredInvoices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Generar factura manual',
            onPressed: _showGenerateDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _SummaryCard(
                  label: 'Facturado',
                  value: '${_totalPurchases.toStringAsFixed(2)}${AppConfig.currency}',
                  color: AppColors.success,
                  icon: Icons.trending_up,
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  label: 'Abonado',
                  value: '-${_totalReturns.toStringAsFixed(2)}${AppConfig.currency}',
                  color: AppColors.error,
                  icon: Icons.trending_down,
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  label: 'Neto',
                  value: '${(_totalPurchases - _totalReturns).toStringAsFixed(2)}${AppConfig.currency}',
                  color: AppColors.arena,
                  icon: Icons.account_balance,
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar factura...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('Todo')),
                    ButtonSegment(value: 'purchase', label: Text('Compra')),
                    ButtonSegment(value: 'return', label: Text('Abono')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (s) {
                    setState(() => _filter = s.first);
                    _load();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: filtered.isEmpty
                        ? const Center(child: Text('No hay facturas'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) => _InvoiceCard(
                              invoice: filtered[i],
                              onDownload: () => _downloadInvoice(filtered[i]),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.arenaLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onDownload;

  const _InvoiceCard({required this.invoice, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(invoice.createdAt);
    final dateStr = createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt) : '';
    final isReturn = invoice.isReturn;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isReturn ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isReturn ? Icons.replay : Icons.receipt_long,
            color: isReturn ? AppColors.error : AppColors.success,
          ),
        ),
        title: Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invoice.customerName ?? 'Sin nombre', style: const TextStyle(fontSize: 12)),
            Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isReturn ? "-" : ""}${invoice.amount.abs().toStringAsFixed(2)}${AppConfig.currency}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isReturn ? AppColors.error : AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.download, size: 20),
              onPressed: onDownload,
              tooltip: 'Descargar PDF',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
