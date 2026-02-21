class CartItem {
  final String productId;
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;
  final int stock;

  const CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    required this.stock,
  });

  double get total => price * quantity;

  CartItem copyWith({int? quantity, int? stock}) {
    return CartItem(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      price: price,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'name': name,
    'image_url': imageUrl,
    'quantity': quantity,
    'price': price,
    'stock': stock,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
    );
  }
}
