import 'package:by_arena/core/config/app_config.dart';

class WishlistItem {
  final String id;
  final String userId;
  final String productId;
  final String? addedAt;
  final WishlistProduct? product;

  const WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    this.addedAt,
    this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? '',
      addedAt: json['added_at'],
      product: json['product'] != null
          ? WishlistProduct.fromJson(json['product'])
          : null,
    );
  }
}

class WishlistProduct {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int stock;
  final bool active;
  final bool onOffer;
  final double? offerPrice;

  const WishlistProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.active,
    this.onOffer = false,
    this.offerPrice,
  });

  double get effectivePrice =>
      (onOffer && offerPrice != null) ? offerPrice! : price;
  bool get isAvailable => active && stock > 0;

  factory WishlistProduct.fromJson(Map<String, dynamic> json) {
    return WishlistProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: AppConfig.resolveImageUrl(json['image_url'] ?? ''),
      stock: json['stock'] ?? 0,
      active: json['active'] ?? true,
      onOffer: json['on_offer'] ?? false,
      offerPrice: json['offer_price']?.toDouble(),
    );
  }
}
