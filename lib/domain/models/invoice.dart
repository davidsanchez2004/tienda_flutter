class Invoice {
  final String id;
  final String? orderId;
  final String? returnId;
  final String invoiceNumber;
  final String type; // 'purchase' | 'return'
  final double amount;
  final String? customerName;
  final String? customerEmail;
  final String createdAt;

  const Invoice({
    required this.id,
    this.orderId,
    this.returnId,
    required this.invoiceNumber,
    required this.type,
    required this.amount,
    this.customerName,
    this.customerEmail,
    required this.createdAt,
  });

  bool get isPurchase => type == 'purchase';
  bool get isReturn => type == 'return';

  String get typeLabel => isPurchase ? 'Factura' : 'Nota de Crédito';

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      orderId: json['order_id'],
      returnId: json['return_id'],
      invoiceNumber: json['invoice_number'] ?? '',
      type: json['type'] ?? 'purchase',
      amount: (json['amount'] ?? 0).toDouble(),
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
