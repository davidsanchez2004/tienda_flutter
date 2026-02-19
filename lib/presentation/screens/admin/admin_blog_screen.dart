import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';
import 'package:intl/intl.dart';

class AdminBlogScreen extends ConsumerStatefulWidget {
  const AdminBlogScreen({super.key});

  @override
  ConsumerState<AdminBlogScreen> createState() => _AdminBlogScreenState();
}

class _AdminBlogScreenState extends ConsumerState<AdminBlogScreen> {
  List<dynamic> _posts = [];
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
      final posts = await repo.getBlogPosts();
      if (mounted) setState(() { _posts = posts; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar artículo'),
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
        await repo.deleteBlogPost(id);
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showPostForm({Map<String, dynamic>? post}) {
    final titleC = TextEditingController(text: post?['title'] ?? '');
    final slugC = TextEditingController(text: post?['slug'] ?? '');
    final excerptC = TextEditingController(text: post?['excerpt'] ?? '');
    final contentC = TextEditingController(text: post?['content'] ?? '');
    final imageC = TextEditingController(text: post?['image_url'] ?? '');
    final authorC = TextEditingController(text: post?['author'] ?? '');
    bool published = post?['published'] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.9,
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
                    Text(post != null ? 'Editar Artículo' : 'Nuevo Artículo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: slugC, decoration: const InputDecoration(labelText: 'Slug', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: authorC, decoration: const InputDecoration(labelText: 'Autor', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: excerptC, decoration: const InputDecoration(labelText: 'Extracto', border: OutlineInputBorder()), maxLines: 2),
                    const SizedBox(height: 12),
                    TextField(controller: contentC, decoration: const InputDecoration(labelText: 'Contenido (HTML/Markdown)', border: OutlineInputBorder()), maxLines: 8),
                    const SizedBox(height: 12),
                    TextField(controller: imageC, decoration: const InputDecoration(labelText: 'URL imagen', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Publicado'),
                      value: published,
                      activeColor: AppColors.arena,
                      onChanged: (v) => setSheetState(() => published = v),
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
                        'title': titleC.text,
                        'slug': slugC.text.isNotEmpty ? slugC.text : titleC.text.toLowerCase().replaceAll(' ', '-'),
                        'excerpt': excerptC.text,
                        'content': contentC.text,
                        'image_url': imageC.text,
                        'author': authorC.text,
                        'published': published,
                      };
                      try {
                        final repo = ref.read(adminRepositoryProvider);
                        if (post != null) {
                          await repo.updateBlogPost(post['id'], data);
                        } else {
                          await repo.createBlogPost(data);
                        }
                        if (mounted) Navigator.pop(ctx);
                        _load();
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.arena, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(post != null ? 'Actualizar' : 'Crear Artículo'),
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
      appBar: AppBar(title: const Text('Gestionar Blog')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostForm(),
        backgroundColor: AppColors.arena,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _load,
              child: _posts.isEmpty
                  ? const Center(child: Text('No hay artículos'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _posts.length,
                      itemBuilder: (ctx, i) {
                        final p = _posts[i] as Map<String, dynamic>;
                        final published = p['published'] == true;
                        final createdAt = DateTime.tryParse(p['created_at'] ?? '');
                        final dateStr = createdAt != null ? DateFormat('dd/MM/yyyy').format(createdAt) : '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: p['image_url'] != null && (p['image_url'] as String).isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(p['image_url'], width: 50, height: 50, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: AppColors.arenaPale, child: const Icon(Icons.article, color: AppColors.arena))),
                                  )
                                : Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.arenaPale, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.article, color: AppColors.arena)),
                            title: Text(p['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Row(
                              children: [
                                Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: published ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(published ? 'Publicado' : 'Borrador', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: published ? Colors.green : Colors.grey)),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (v) {
                                if (v == 'edit') _showPostForm(post: p);
                                if (v == 'delete') _delete(p['id'].toString());
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
