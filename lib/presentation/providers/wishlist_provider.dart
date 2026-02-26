import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:by_arena/data/repositories/wishlist_repository.dart';
import 'package:by_arena/domain/models/wishlist_item.dart';
import 'package:by_arena/presentation/providers/auth_provider.dart';

class WishlistNotifier extends StateNotifier<AsyncValue<List<WishlistItem>>> {
  final WishlistRepository _repo;
  WishlistNotifier(this._repo) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.getWishlist();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggle(String productId) async {
    final current = state.valueOrNull ?? [];
    final isInWishlist = current.any((i) => i.productId == productId);

    try {
      if (isInWishlist) {
        await _repo.removeFromWishlist(productId);
      } else {
        await _repo.addToWishlist(productId);
      }
      await load(); // Refresh from server
    } catch (e) {
      rethrow;
    }
  }

  bool isInWishlist(String productId) {
    return state.valueOrNull?.any((i) => i.productId == productId) ?? false;
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, AsyncValue<List<WishlistItem>>>(
        (ref) {
  final repo = ref.read(wishlistRepositoryProvider);
  final notifier = WishlistNotifier(repo);

  // Only load if user is authenticated
  final authState = ref.watch(authProvider);
  if (authState.status == AuthStatus.authenticated) {
    notifier.load();
  }

  return notifier;
});

/// Check if a specific product is in the wishlist
final isInWishlistProvider = Provider.family<bool, String>((ref, productId) {
  final wishlist = ref.watch(wishlistProvider);
  return wishlist.valueOrNull?.any((i) => i.productId == productId) ?? false;
});
