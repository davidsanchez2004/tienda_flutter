import 'package:flutter/material.dart';
import 'package:by_arena/core/theme/app_theme.dart';

/// Generic legal text screen used for Terms, Privacy, Cookies, and Returns Policy.
class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({super.key, required this.title, required this.content});

  // Factory constructors for each legal page
  factory LegalScreen.terms() => const LegalScreen(
    title: 'Términos y Condiciones',
    content: '''
TÉRMINOS Y CONDICIONES DE USO - BY ARENA

1. OBJETO
Las presentes condiciones regulan el uso del servicio de venta online de BY ARENA.

2. IDENTIFICACIÓN
BY ARENA es una marca dedicada a la venta de joyería y accesorios premium.

3. PRODUCTOS Y PRECIOS
Los precios indicados incluyen IVA. BY ARENA se reserva el derecho de modificar precios sin previo aviso, aunque los pedidos confirmados mantendrán el precio vigente en el momento de la compra.

4. PROCESO DE COMPRA
El proceso de compra se completa tras la confirmación del pago a través de nuestra pasarela segura (Stripe). Recibirás un email de confirmación con los detalles de tu pedido.

5. ENVÍOS
— Envío estándar (3-5 días laborables): 4,95€
— Envío gratuito en pedidos superiores a 50€
— Zona de envío: España peninsular e Islas Baleares

6. DEVOLUCIONES
Dispones de 14 días naturales desde la recepción para solicitar una devolución. Los artículos deben estar en su estado original.

7. PROTECCIÓN DE DATOS
Tus datos personales se tratan según nuestra Política de Privacidad y la normativa RGPD vigente.

8. LEY APLICABLE
Estas condiciones se rigen por la legislación española.
''',
  );

  factory LegalScreen.privacy() => const LegalScreen(
    title: 'Política de Privacidad',
    content: '''
POLÍTICA DE PRIVACIDAD - BY ARENA

1. RESPONSABLE DEL TRATAMIENTO
BY ARENA es responsable del tratamiento de los datos personales que nos proporciones.

2. DATOS QUE RECOPILAMOS
— Datos de identificación: nombre, email, teléfono
— Datos de envío: dirección postal
— Datos de pago: procesados directamente por Stripe (no almacenamos datos de tarjeta)
— Datos de navegación: cookies técnicas y analíticas

3. FINALIDAD DEL TRATAMIENTO
— Gestión de pedidos y envíos
— Comunicaciones sobre el estado de tu pedido
— Newsletter (solo con consentimiento explícito)
— Mejora del servicio

4. CONSERVACIÓN DE DATOS
Conservamos tus datos mientras mantengas tu cuenta activa y durante los plazos legales aplicables.

5. TUS DERECHOS
Puedes ejercer tus derechos de acceso, rectificación, supresión, portabilidad, limitación y oposición escribiéndonos a nuestro email de contacto.

6. SEGURIDAD
Utilizamos medidas técnicas y organizativas para proteger tus datos, incluyendo cifrado SSL y almacenamiento seguro.
''',
  );

  factory LegalScreen.cookies() => const LegalScreen(
    title: 'Política de Cookies',
    content: '''
POLÍTICA DE COOKIES - BY ARENA

1. ¿QUÉ SON LAS COOKIES?
Las cookies son pequeños archivos de texto que se almacenan en tu dispositivo al visitar nuestra web.

2. COOKIES QUE UTILIZAMOS
— Cookies técnicas: necesarias para el funcionamiento de la web
— Cookies de sesión: mantienen tu sesión activa y tu carrito de compra
— Cookies analíticas: nos ayudan a entender cómo se usa la web (Google Analytics)

3. GESTIÓN DE COOKIES
Puedes configurar tu navegador para bloquear o eliminar cookies. Ten en cuenta que algunas funcionalidades podrían verse afectadas.

4. ACTUALIZACIÓN
Esta política puede actualizarse periódicamente. Te recomendamos revisarla de vez en cuando.
''',
  );

  factory LegalScreen.returns() => const LegalScreen(
    title: 'Política de Devoluciones',
    content: '''
POLÍTICA DE DEVOLUCIONES - BY ARENA

1. PLAZO DE DEVOLUCIÓN
Dispones de 14 días naturales desde la recepción del pedido para solicitar una devolución.

2. CONDICIONES
— Los artículos deben estar sin usar y en su embalaje original
— Deben mantener todas las etiquetas
— No se aceptan devoluciones de artículos personalizados

3. PROCESO
1. Accede a "Mis Pedidos" y selecciona el pedido
2. Pulsa "Solicitar Devolución" y selecciona los artículos
3. Indica el motivo de la devolución
4. Recibirás un email con las instrucciones de envío

4. GASTOS DE DEVOLUCIÓN
Los gastos de envío de devolución corren a cargo del cliente, salvo que el artículo sea defectuoso o el envío sea incorrecto.

5. REEMBOLSO
Una vez recibido y verificado el artículo, realizaremos el reembolso en un plazo de 5-10 días laborables por el mismo método de pago utilizado.
''',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          content.trim(),
          style: const TextStyle(fontSize: 14, height: 1.7, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
