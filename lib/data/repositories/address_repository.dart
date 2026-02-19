import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/core/network/dio_client.dart';
import 'package:by_arena/domain/models/address.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.watch(dioProvider));
});

class AddressRepository {
  final Dio _dio;
  AddressRepository(this._dio);

  Future<List<Address>> getAddresses() async {
    final res = await _dio.get('/addresses');
    final list = res.data['addresses'] as List? ?? [];
    return list.map((e) => Address.fromJson(e)).toList();
  }

  Future<Address> createAddress(Address address) async {
    final res = await _dio.post('/addresses', data: address.toJson());
    return Address.fromJson(res.data['address']);
  }

  Future<void> deleteAddress(String id) async {
    await _dio.delete('/addresses', data: {'address_id': id});
  }
}
