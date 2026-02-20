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
      case 'completed': return Colors.green.shade800;
      case 'rejected': return Colors.red;
      case 'processing': return AppColors.arena;
      default: return AppColors.textSecondary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'approved': return 'Aprobado';
      case 'completed': return 'Completado';
      case 'rejected': return 'Rechazado';
      case 'processing': return 'Procesando';
      case 'pending': return 'Pendiente';
      default: return status ?? 'Desconocido';
    }
  }

  Future<void> _updateReturnStatus(Map<String, dynamic> returnData, String newStatus) async {
    final notesCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${newStatus == 'approved' ? 'Aprobar' : newStatus == 'rejected' ? 'Rechazar' : newStatus == 'completed' ? 'Completar' : 'Actualizar'} Devolución'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Cambiar estado a "${_statusLabel(newStatus)}"?'),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notas del admin (opcional)',
                hintText: 'Observaciones...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'rejected' ? AppColors.error : AppColors.arena,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.updateReturn(
          returnId: returnData['id'],
          status: newStatus,
          adminNotes: notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Devolución actualizada a ${_statusLabel(newStatus)}')),
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
    notesCtrl.dispose();
  }

  List<String> _getAvailableActions(String? currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['approved', 'rejected'];
      case 'approved':
        return ['processing', 'completed', 'rejected'];
      case 'processing':
        return ['completed', 'rejected'];
      default:
        return [];
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
                        final actions = _getAvailableActions(r['status']);
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
                                    Flexible(
                                      child: Text(
                                        'Pedido: #${(r['order_id'] ?? '').toString().length >= 8 ? (r['order_id'] ?? '').toString().substring(0, 8) : r['order_id'] ?? ''}...',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
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
                                if (r['admin_notes'] != null && r['admin_notes'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text('Admin: ${r['admin_notes']}', style: const TextStyle(fontSize: 12, color: AppColors.arena, fontStyle: FontStyle.italic)),
                                ],
                                const SizedBox(height: 4),
                                Text(dateStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                if (r['customer_email'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Email: ${r['customer_email']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                                if (r['refund_amount'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Importe: ${(r['refund_amount'] as num).toStringAsFixed(2)}€', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                                // Action buttons
                                if (actions.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children: actions.map((action) {
                                      Color btnColor;
                                      String btnLabel;
                                      IconData btnIcon;
                                      switch (action) {
                                        case 'approved':
                                          btnColor = Colors.green;
                                          btnLabel = 'Aprobar';
                                          btnIcon = Icons.check_circle_outline;
                                          break;
                                        case 'rejected':
                                          btnColor = Colors.red;
                                          btnLabel = 'Rechazar';
                                          btnIcon = Icons.cancel_outlined;
                                          break;
                                        case 'processing':
                                          btnColor = AppColors.arena;
                                          btnLabel = 'Procesando';
                                          btnIcon = Icons.autorenew;
                                          break;
                                        case 'completed':
                                          btnColor = Colors.green.shade800;
                                          btnLabel = 'Completar';
                                          btnIcon = Icons.done_all;
                                          break;
                                        default:
                                          btnColor = AppColors.textSecondary;
                                          btnLabel = action;
                                          btnIcon = Icons.edit;
                                      }
                                      return OutlinedButton.icon(
                                        onPressed: () => _updateReturnStatus(r, action),
                                        icon: Icon(btnIcon, size: 16),
                                        label: Text(btnLabel, style: const TextStyle(fontSize: 12)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: btnColor,
                                          side: BorderSide(color: btnColor),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      );
                                    }).toList(),
                                  ),
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
