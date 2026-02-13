import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:by_arena/domain/models/cart_item.dart';
import 'package:by_arena/core/config/app_config.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _loadFromStorage();
  }

  static const _storageKey = 'cart_items';

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_storageKey);
      if (json != null) {
        final list = jsonDecode(json) as List;
        state = list.map((e) => CartItem.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, json);
    } catch (_) {}
  }

  double get subtotal => state.fold(0, (sum, item) => sum + item.total);
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
  double get shippingCost =>
      subtotal >= AppConfig.freeShippingThreshold ? 0 : AppConfig.shippingCost;
  double get total => subtotal + shippingCost;

  void addItem(CartItem item) {
    final index = state.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      final existing = state[index];
      final maxStock = item.stock > 0 ? item.stock : existing.stock;
      final newQty = (existing.quantity + item.quantity).clamp(1, maxStock);
      final updated = existing.copyWith(quantity: newQty, stock: maxStock);
      state = [...state]..[index] = updated;
    } else {
      final clamped = item.copyWith(quantity: item.quantity.clamp(1, item.stock));
      state = [...state, clamped];
    }
    _saveToStorage();
  }

  void removeItem(String productId) {
    state = state.where((item) => item.productId != productId).toList();
    _saveToStorage();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final index = state.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      final item = state[index];
      final clamped = quantity.clamp(1, item.stock);
      state = [...state]..[index] = item.copyWith(quantity: clamped);
      _saveToStorage();
    }
  }

  void clear() {
    state = [];
    _saveToStorage();
  }

  List<Map<String, dynamic>> toApiItems() {
    return state.map((item) => item.toJson()).toList();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Derived providers for easy access
final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.total);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

final cartShippingProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return subtotal >= AppConfig.freeShippingThreshold ? 0 : AppConfig.shippingCost;
});

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartSubtotalProvider) + ref.watch(cartShippingProvider);
});
