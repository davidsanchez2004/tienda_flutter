import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';

class AdminNewsletterScreen extends ConsumerStatefulWidget {
  const AdminNewsletterScreen({super.key});

  @override
  ConsumerState<AdminNewsletterScreen> createState() => _AdminNewsletterScreenState();
}

class _AdminNewsletterScreenState extends ConsumerState<AdminNewsletterScreen> {
  Map<String, dynamic>? _stats;
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
      final stats = await repo.getNewsletterStats();
      if (mounted) setState(() { _stats = stats; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Newsletter')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.arenaLight),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.mail_outline, size: 48, color: AppColors.arena),
                        const SizedBox(height: 12),
                        Text(
                          '${_stats?['total_subscribers'] ?? _stats?['count'] ?? 0}',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.arena),
                        ),
                        const Text('Suscriptores totales', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_stats?['subscribers'] != null) ...[
                    const Text('Últimos suscriptores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...(_stats!['subscribers'] as List).take(20).map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppColors.arenaPale, child: Icon(Icons.person, color: AppColors.arena)),
                        title: Text(s['email'] ?? '', style: const TextStyle(fontSize: 14)),
                        subtitle: Text(s['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                    )),
                  ],
                  if (_stats?['recent'] != null) ...[
                    const Text('Últimos suscriptores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...(_stats!['recent'] as List).take(20).map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppColors.arenaPale, child: Icon(Icons.person, color: AppColors.arena)),
                        title: Text(s['email'] ?? '', style: const TextStyle(fontSize: 14)),
                        subtitle: Text(s['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ),
                    )),
                  ],
                ],
              ),
            ),
    );
  }
}
