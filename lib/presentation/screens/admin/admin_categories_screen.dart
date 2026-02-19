import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  List<dynamic> _categories = [];
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
      final categories = await repo.getCategories();
      if (mounted) setState(() { _categories = categories; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: const Text('¿Estás seguro? Los productos de esta categoría quedarán sin categoría.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.deleteCategory(id);
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showForm({Map<String, dynamic>? category}) {
    final nameC = TextEditingController(text: category?['name'] ?? '');
    final slugC = TextEditingController(text: category?['slug'] ?? '');
    final descC = TextEditingController(text: category?['description'] ?? '');
    final imageC = TextEditingController(text: category?['image_url'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category != null ? 'Editar Categoría' : 'Nueva Categoría'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: slugC, decoration: const InputDecoration(labelText: 'Slug', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 12),
              TextField(controller: imageC, decoration: const InputDecoration(labelText: 'URL imagen', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'name': nameC.text,
                'slug': slugC.text.isNotEmpty ? slugC.text : nameC.text.toLowerCase().replaceAll(' ', '-'),
                'description': descC.text,
                'image_url': imageC.text,
              };
              try {
                final repo = ref.read(adminRepositoryProvider);
                if (category != null) {
                  await repo.updateCategory(category['id'], data);
                } else {
                  await repo.createCategory(data);
                }
                if (mounted) Navigator.pop(ctx);
                _load();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.arena),
            child: Text(category != null ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Categorías')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.arena,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _load,
              child: _categories.isEmpty
                  ? const Center(child: Text('No hay categorías'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _categories.length,
                      itemBuilder: (ctx, i) {
                        final c = _categories[i] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: AppColors.arenaPale, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.category, color: AppColors.arena),
                            ),
                            title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(c['slug'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showForm(category: c)),
                                IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _delete(c['id'].toString())),
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
