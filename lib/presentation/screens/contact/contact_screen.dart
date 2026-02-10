import 'package:flutter/material.dart';
import 'package:by_arena/core/theme/app_theme.dart';
import 'package:by_arena/data/repositories/contact_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(contactRepositoryProvider);
      await repo.sendContactMessage(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        subject: _subjectCtrl.text.trim(),
        message: _messageCtrl.text.trim(),
      );
      setState(() => _sent = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contacto')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 64, color: AppColors.success),
                const SizedBox(height: 16),
                const Text('Mensaje enviado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Te responderemos lo antes posible.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Contacto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('¿Tienes alguna pregunta?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Escríbenos y te responderemos lo antes posible.',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          // WhatsApp shortcut
          OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse('https://wa.me/${AppConfig.whatsappNumber}')),
            icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
            label: const Text('Escríbenos por WhatsApp'),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outlined)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains('@') ? null : 'Email no válido',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Asunto', prefixIcon: Icon(Icons.subject)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _messageCtrl,
                  decoration: const InputDecoration(labelText: 'Mensaje', alignLabelWithHint: true),
                  maxLines: 5,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar Mensaje'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
