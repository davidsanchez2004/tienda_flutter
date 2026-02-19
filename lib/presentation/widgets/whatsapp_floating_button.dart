import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:by_arena/core/config/app_config.dart';

class WhatsAppFloatingButton extends StatefulWidget {
  const WhatsAppFloatingButton({super.key});

  @override
  State<WhatsAppFloatingButton> createState() => _WhatsAppFloatingButtonState();
}

class _WhatsAppFloatingButtonState extends State<WhatsAppFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final number = AppConfig.whatsappNumber.replaceAll('+', '').replaceAll(' ', '');
    final message = Uri.encodeComponent('Hola, tengo una consulta sobre BY ARENA');
    final url = Uri.parse('https://wa.me/$number?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton(
        heroTag: 'whatsapp_fab',
        onPressed: _openWhatsApp,
        backgroundColor: const Color(0xFF25D366),
        elevation: 4,
        child: const Icon(
          Icons.chat,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
