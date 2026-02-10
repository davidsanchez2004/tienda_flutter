import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/data/repositories/wishlist_repository.dart';
import 'package:by_arena/domain/models/product.dart';

// Wishlist state
class WishlistState {
  final List<Product> items;
  final bool isLoading;
  final String? error;

  const WishlistState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  WishlistState copyWith({
    List<Product>? items,
    bool? isLoading,
    String? error,
  }) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool containsProduct(String productId) {
    return items.any((p) => p.id == productId);
  }
}

// Wishlist notifier
class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistRepository _repo;

  WishlistNotifier(this._repo) : super(const WishlistState());

  Future<void> loadWishlist() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.getWishlist();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleWishlist(Product product) async {
    final isInWishlist = state.containsProduct(product.id);
    try {
      if (isInWishlist) {
        // Optimistic remove
        state = state.copyWith(
          items: state.items.where((p) => p.id != product.id).toList(),
        );
        await _repo.removeFromWishlist(product.id);
      } else {
        // Optimistic add
        state = state.copyWith(items: [...state.items, product]);
        await _repo.addToWishlist(product.id);
      }
    } catch (e) {
      // Revert on error
      await loadWishlist();
    }
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier(ref.watch(wishlistRepositoryProvider));
});
