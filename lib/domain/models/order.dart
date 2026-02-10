class Order {
  final String id;
  final String? userId;
  final String status;
  final double subtotal;
  final double shippingCost;
  final double total;
  final String shippingOption;
  final Map<String, dynamic>? shippingAddress;
  final String? trackingNumber;
  final String? carrier;
  final String? guestEmail;
  final String? guestFirstName;
  final String? guestLastName;
  final String? paymentStatus;
  final List<OrderItem> items;
  final String createdAt;
  final String updatedAt;

  const Order({
    required this.id,
    this.userId,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.shippingOption,
    this.shippingAddress,
    this.trackingNumber,
    this.carrier,
    this.guestEmail,
    this.guestFirstName,
    this.guestLastName,
    this.paymentStatus,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  String get orderNumber => id.substring(0, 8).toUpperCase();

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'paid': return 'Pagado';
      case 'shipped': return 'Enviado';
      case 'delivered': return 'Entregado';
      case 'cancelled': return 'Cancelado';
      default: return status;
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['items'] != null) {
      items = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['id'] ?? '',
      userId: json['user_id'],
      status: json['status'] ?? 'pending',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingCost: (json['shipping_cost'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      shippingOption: json['shipping_option'] ?? 'home',
      shippingAddress: json['shipping_address'] is Map
          ? Map<String, dynamic>.from(json['shipping_address'])
          : null,
      trackingNumber: json['tracking_number'],
      carrier: json['carrier'],
      guestEmail: json['guest_email'],
      guestFirstName: json['guest_first_name'],
      guestLastName: json['guest_last_name'],
      paymentStatus: json['payment_status'],
      items: items,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final double total;
  final String? productName;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.total,
    this.productName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      productId: json['product_id'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      productName: json['product_name'],
    );
  }
}
