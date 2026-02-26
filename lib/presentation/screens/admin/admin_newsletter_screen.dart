import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';

class AdminNewsletterScreen extends ConsumerStatefulWidget {
  const AdminNewsletterScreen({super.key});

  @override
  ConsumerState<AdminNewsletterScreen> createState() =>
      _AdminNewsletterScreenState();
}

class _AdminNewsletterScreenState extends ConsumerState<AdminNewsletterScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _subscribers = [];
  Map<String, dynamic> _stats = {};
  String _filterStatus = 'all'; // all, confirmed, pending, unsubscribed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!AdminRepository.isAdminLoggedIn) {
      if (mounted) context.go('/admin-login');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final data = await repo.getNewsletterStats();
      if (mounted) {
        setState(() {
          _subscribers = ((data['subscribers'] as List?) ?? [])
              .cast<Map<String, dynamic>>();
          _stats = (data['stats'] as Map<String, dynamic>?) ?? {};
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredSubscribers {
    if (_filterStatus == 'all') return _subscribers;
    return _subscribers
        .where((s) => (s['status'] ?? '') == _filterStatus)
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'unsubscribed':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmado';
      case 'pending':
        return 'Pendiente';
      case 'unsubscribed':
        return 'Dado de baja';
      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_top;
      case 'unsubscribed':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _stats['total'] ?? _subscribers.length;
    final confirmed = _stats['confirmed'] ?? 0;
    final pending = _stats['pending'] ?? 0;
    final unsubscribed = _stats['unsubscribed'] ?? 0;
    final filtered = _filteredSubscribers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Newsletter'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats summary cards
                  Row(
                    children: [
                      _StatChip(
                        label: 'Total',
                        value: '$total',
                        color: AppColors.arena,
                        icon: Icons.people,
                        selected: _filterStatus == 'all',
                        onTap: () => setState(() => _filterStatus = 'all'),
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Confirmados',
                        value: '$confirmed',
                        color: Colors.green,
                        icon: Icons.check_circle,
                        selected: _filterStatus == 'confirmed',
                        onTap: () =>
                            setState(() => _filterStatus = 'confirmed'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatChip(
                        label: 'Pendientes',
                        value: '$pending',
                        color: Colors.orange,
                        icon: Icons.hourglass_top,
                        selected: _filterStatus == 'pending',
                        onTap: () => setState(() => _filterStatus = 'pending'),
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        label: 'Baja',
                        value: '$unsubscribed',
                        color: Colors.grey,
                        icon: Icons.cancel,
                        selected: _filterStatus == 'unsubscribed',
                        onTap: () =>
                            setState(() => _filterStatus = 'unsubscribed'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Text(
                    _filterStatus == 'all'
                        ? 'Todos los suscriptores (${filtered.length})'
                        : '${_statusLabel(_filterStatus)} (${filtered.length})',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.inbox,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('No hay suscriptores',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  else
                    ...filtered.map((s) {
                      final email = s['email'] ?? '';
                      final status = (s['status'] ?? 'pending').toString();
                      final createdAt =
                          s['created_at'] ?? s['subscribed_at'] ?? '';
                      String dateStr = '';
                      if (createdAt.toString().isNotEmpty) {
                        try {
                          final dt = DateTime.parse(createdAt.toString());
                          dateStr =
                              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
                        } catch (_) {}
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.arenaLight),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _statusColor(status).withValues(alpha: 0.15),
                            child: Icon(_statusIcon(status),
                                color: _statusColor(status), size: 20),
                          ),
                          title: Text(
                            email,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: dateStr.isNotEmpty
                              ? Text('Suscrito: $dateStr',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600))
                              : null,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _statusColor(status).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel(status),
                              style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.arenaLight,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
