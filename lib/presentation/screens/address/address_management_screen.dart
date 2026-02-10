import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/domain/models/address.dart';
import 'package:by_arena/presentation/providers/address_provider.dart';
import 'package:by_arena/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AddressManagementScreen extends ConsumerStatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  ConsumerState<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends ConsumerState<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(addressProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    if (auth.status != AuthStatus.authenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Direcciones')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Inicia sesión para gestionar tus direcciones'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.push('/login'), child: const Text('Iniciar Sesión')),
            ],
          ),
        ),
      );
    }

    final state = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Direcciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddressForm(context),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off, size: 64, color: AppColors.arenaLight),
                      const SizedBox(height: 16),
                      const Text('No tienes direcciones guardadas',
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddressForm(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir Dirección'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(addressProvider.notifier).load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final addr = state.addresses[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: addr.isDefault ? AppColors.arena : AppColors.arenaLight,
                            width: addr.isDefault ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(addr.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                                if (addr.isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.arenaPale,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Principal',
                                        style: TextStyle(fontSize: 11, color: AppColors.arena)),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outlined, size: 20, color: AppColors.error),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Eliminar dirección'),
                                        content: const Text('¿Seguro que quieres eliminar esta dirección?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: AppColors.error))),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      ref.read(addressProvider.notifier).delete(addr.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(addr.fullAddress, style: const TextStyle(color: AppColors.textSecondary)),
                            Text('${addr.phone} · ${addr.email}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showAddressForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final streetCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final aptCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final stateCtrl = TextEditingController();
    final postalCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Nueva Dirección', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre completo'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
                const SizedBox(height: 10),
                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => v!.contains('@') ? null : 'Email no válido'),
                const SizedBox(height: 10),
                TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Teléfono'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(flex: 3, child: TextFormField(controller: streetCtrl, decoration: const InputDecoration(labelText: 'Calle'), validator: (v) => v!.isEmpty ? 'Requerido' : null)),
                  const SizedBox(width: 8),
                  Expanded(flex: 1, child: TextFormField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'Nº'), validator: (v) => v!.isEmpty ? 'Req.' : null)),
                ]),
                const SizedBox(height: 10),
                TextFormField(controller: aptCtrl, decoration: const InputDecoration(labelText: 'Piso/Puerta (opcional)')),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextFormField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'Ciudad'), validator: (v) => v!.isEmpty ? 'Requerido' : null)),
                  const SizedBox(width: 8),
                  Expanded(child: TextFormField(controller: stateCtrl, decoration: const InputDecoration(labelText: 'Provincia'), validator: (v) => v!.isEmpty ? 'Requerido' : null)),
                ]),
                const SizedBox(height: 10),
                TextFormField(controller: postalCtrl, decoration: const InputDecoration(labelText: 'Código Postal'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final address = Address(
                      id: '',
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      street: streetCtrl.text.trim(),
                      number: numberCtrl.text.trim(),
                      apartment: aptCtrl.text.trim().isNotEmpty ? aptCtrl.text.trim() : null,
                      city: cityCtrl.text.trim(),
                      state: stateCtrl.text.trim(),
                      postalCode: postalCtrl.text.trim(),
                    );
                    ref.read(addressProvider.notifier).add(address);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: const Text('Guardar Dirección'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
