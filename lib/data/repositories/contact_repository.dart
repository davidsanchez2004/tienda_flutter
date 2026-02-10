import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  return ContactRepository(ref.watch(dioProvider));
});

class ContactRepository {
  final Dio _dio;
  ContactRepository(this._dio);

  Future<void> sendContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    await _dio.post('/api/email/send-branded', data: {
      'template': 'contact',
      'to': email,
      'data': {
        'customerName': name,
        'customerEmail': email,
        'subject': subject,
        'message': message,
      },
    });
  }

  Future<void> subscribeNewsletter(String email, {String? name}) async {
    await _dio.post('/api/newsletter/subscribe', data: {
      'email': email,
      'name': name,
    });
  }
}
