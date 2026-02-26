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
                const Icon(Icons.check_circle,
                    size: 64, color: AppColors.success),
                const SizedBox(height: 16),
                const Text('Mensaje enviado',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Te responderemos lo antes posible.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver')),
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
            onPressed: () => launchUrl(
                Uri.parse('https://wa.me/${AppConfig.whatsappNumber}')),
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
                  decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outlined)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains('@') ? null : 'Email no válido',
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Asunto', prefixIcon: Icon(Icons.subject)),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _messageCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Mensaje', alignLabelWithHint: true),
                  maxLines: 5,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52)),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar Mensaje'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const _NewsletterCard(),
        ],
      ),
    );
  }
}

class _NewsletterCard extends ConsumerStatefulWidget {
  const _NewsletterCard();

  @override
  ConsumerState<_NewsletterCard> createState() => _NewsletterCardState();
}

class _NewsletterCardState extends ConsumerState<_NewsletterCard> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _subscribed = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final email = _emailCtrl.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un email válido')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(contactRepositoryProvider);
      await repo.subscribeNewsletter(email);
      setState(() => _subscribed = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_subscribed) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: const Column(
          children: [
            Icon(Icons.mark_email_read, size: 40, color: AppColors.success),
            SizedBox(height: 12),
            Text('¡Suscripción enviada!',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            SizedBox(height: 4),
            Text('Revisa tu correo para confirmar tu suscripción.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D2D2D), Color(0xFF4A4A4A)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mail_outline, color: AppColors.gold, size: 24),
              SizedBox(width: 10),
              Text('Newsletter',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Suscríbete y recibe un 10% de descuento en tu primera compra',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'tu@email.com',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _loading ? null : _subscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Suscribir'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
