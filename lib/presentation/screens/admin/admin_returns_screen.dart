import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';
import 'package:intl/intl.dart';

class AdminReturnsScreen extends ConsumerStatefulWidget {
  const AdminReturnsScreen({super.key});

  @override
  ConsumerState<AdminReturnsScreen> createState() => _AdminReturnsScreenState();
}

class _AdminReturnsScreenState extends ConsumerState<AdminReturnsScreen> {
  List<dynamic> _returns = [];
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
      final returns = await repo.getReturns();
      if (mounted) setState(() { _returns = returns; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'processing': return AppColors.arena;
      default: return AppColors.textSecondary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'approved': return 'Aprobado';
      case 'rejected': return 'Rechazado';
      case 'processing': return 'Procesando';
      case 'pending': return 'Pendiente';
      default: return status ?? 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devoluciones')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _load,
              child: _returns.isEmpty
                  ? const Center(child: Text('No hay solicitudes de devolución'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _returns.length,
                      itemBuilder: (ctx, i) {
                        final r = _returns[i] as Map<String, dynamic>;
                        final createdAt = DateTime.tryParse(r['created_at'] ?? '');
                        final dateStr = createdAt != null ? DateFormat('dd/MM/yyyy').format(createdAt) : '';
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
                                    Text('Pedido: #${(r['order_id'] ?? '').toString().substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(r['status']).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(_statusLabel(r['status']), style: TextStyle(color: _statusColor(r['status']), fontWeight: FontWeight.w600, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Motivo: ${r['reason'] ?? 'No especificado'}', style: const TextStyle(fontSize: 14)),
                                if (r['details'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(r['details'], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                                const SizedBox(height: 4),
                                Text(dateStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                if (r['customer_email'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Email: ${r['customer_email']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
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
