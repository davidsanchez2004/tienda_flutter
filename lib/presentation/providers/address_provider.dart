import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/data/repositories/address_repository.dart';
import 'package:by_arena/domain/models/address.dart';

class AddressState {
  final List<Address> addresses;
  final bool isLoading;
  final String? error;

  const AddressState({this.addresses = const [], this.isLoading = false, this.error});

  AddressState copyWith({List<Address>? addresses, bool? isLoading, String? error}) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  final AddressRepository _repo;
  AddressNotifier(this._repo) : super(const AddressState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final addresses = await _repo.getAddresses();
      state = state.copyWith(addresses: addresses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> add(Address address) async {
    try {
      final created = await _repo.createAddress(address);
      state = state.copyWith(addresses: [...state.addresses, created]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.deleteAddress(id);
      state = state.copyWith(
        addresses: state.addresses.where((a) => a.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier(ref.watch(addressRepositoryProvider));
});
