class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final List<String> imagesUrls;
  final List<String> categoryIds;
  final String? sku;
  final bool featured;
  final bool active;
  final bool onOffer;
  final double? offerPrice;
  final double? offerPercentage;
  final String? offerStartDate;
  final String? offerEndDate;
  final String createdAt;
  final String updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    this.imagesUrls = const [],
    this.categoryIds = const [],
    this.sku,
    this.featured = false,
    this.active = true,
    this.onOffer = false,
    this.offerPrice,
    this.offerPercentage,
    this.offerStartDate,
    this.offerEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  double get effectivePrice => (onOffer && offerPrice != null) ? offerPrice! : price;

  bool get isAvailable => active && stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      imagesUrls: List<String>.from(json['images_urls'] ?? []),
      categoryIds: List<String>.from(json['category_ids'] ?? []),
      sku: json['sku'],
      featured: json['featured'] ?? false,
      active: json['active'] ?? true,
      onOffer: json['on_offer'] ?? false,
      offerPrice: json['offer_price']?.toDouble(),
      offerPercentage: json['offer_percentage']?.toDouble(),
      offerStartDate: json['offer_start_date'],
      offerEndDate: json['offer_end_date'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
    'image_url': imageUrl,
    'images_urls': imagesUrls,
    'category_ids': categoryIds,
    'sku': sku,
    'featured': featured,
    'active': active,
    'on_offer': onOffer,
    'offer_price': offerPrice,
    'offer_percentage': offerPercentage,
  };
}
