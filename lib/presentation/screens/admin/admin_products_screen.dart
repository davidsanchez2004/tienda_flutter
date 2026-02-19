import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/admin_repository.dart';

class AdminProductsScreen extends ConsumerStatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  ConsumerState<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends ConsumerState<AdminProductsScreen> {
  List<dynamic> _products = [];
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
      final results = await Future.wait([repo.getAllProducts(), repo.getCategories()]);
      if (mounted) {
        setState(() {
          _products = results[0];
          _categories = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Estás seguro de que quieres eliminar este producto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        final repo = ref.read(adminRepositoryProvider);
        await repo.deleteProduct(id);
        _load();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showProductForm({Map<String, dynamic>? product}) {
    final nameC = TextEditingController(text: product?['name'] ?? '');
    final descC = TextEditingController(text: product?['description'] ?? '');
    final priceC = TextEditingController(text: product?['price']?.toString() ?? '');
    final salePriceC = TextEditingController(text: product?['sale_price']?.toString() ?? '');
    final stockC = TextEditingController(text: product?['stock']?.toString() ?? '');
    final imageC = TextEditingController(text: product?['image_url'] ?? '');
    final skuC = TextEditingController(text: product?['sku'] ?? '');
    String? selectedCategoryId = product?['category_id'];
    bool isOffer = product?['is_offer'] == true;
    bool isActive = product?['is_active'] ?? true;

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
                  border: Border(bottom: BorderSide(color: AppColors.arenaLight)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product != null ? 'Editar Producto' : 'Nuevo Producto', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _field('Nombre', nameC),
                    _field('Descripción', descC, maxLines: 3),
                    Row(children: [
                      Expanded(child: _field('Precio', priceC, keyboard: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _field('Precio oferta', salePriceC, keyboard: TextInputType.number)),
                    ]),
                    Row(children: [
                      Expanded(child: _field('Stock', stockC, keyboard: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _field('SKU', skuC)),
                    ]),
                    _field('URL imagen', imageC),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                      items: _categories.map((c) => DropdownMenuItem<String>(
                        value: c['id'].toString(),
                        child: Text(c['name'] ?? ''),
                      )).toList(),
                      onChanged: (v) => setSheetState(() => selectedCategoryId = v),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Es oferta'),
                      value: isOffer,
                      activeColor: AppColors.arena,
                      onChanged: (v) => setSheetState(() => isOffer = v),
                    ),
                    SwitchListTile(
                      title: const Text('Activo'),
                      value: isActive,
                      activeColor: AppColors.arena,
                      onChanged: (v) => setSheetState(() => isActive = v),
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
                        'name': nameC.text,
                        'description': descC.text,
                        'price': double.tryParse(priceC.text) ?? 0,
                        'sale_price': salePriceC.text.isNotEmpty ? double.tryParse(salePriceC.text) : null,
                        'stock': int.tryParse(stockC.text) ?? 0,
                        'image_url': imageC.text,
                        'sku': skuC.text,
                        'category_id': selectedCategoryId,
                        'is_offer': isOffer,
                        'is_active': isActive,
                      };
                      try {
                        final repo = ref.read(adminRepositoryProvider);
                        if (product != null) {
                          await repo.updateProduct(product['id'], data);
                        } else {
                          await repo.createProduct(data);
                        }
                        if (mounted) Navigator.pop(ctx);
                        _load();
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(product != null ? 'Producto actualizado' : 'Producto creado')));
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.arena, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(product != null ? 'Actualizar' : 'Crear Producto'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Productos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        backgroundColor: AppColors.arena,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.arena))
          : RefreshIndicator(
              onRefresh: _load,
              child: _products.isEmpty
                  ? const Center(child: Text('No hay productos'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _products.length,
                      itemBuilder: (ctx, i) {
                        final p = _products[i] as Map<String, dynamic>;
                        final price = (p['price'] is num) ? (p['price'] as num).toDouble() : 0.0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: p['image_url'] != null && (p['image_url'] as String).isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(p['image_url'], width: 50, height: 50, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: AppColors.arenaPale, child: const Icon(Icons.image, color: AppColors.arena))),
                                  )
                                : Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.arenaPale, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.inventory_2, color: AppColors.arena)),
                            title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${price.toStringAsFixed(2)} € • Stock: ${p['stock'] ?? 0}'),
                            trailing: PopupMenuButton(
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (v) {
                                if (v == 'edit') _showProductForm(product: p);
                                if (v == 'delete') _deleteProduct(p['id']);
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
