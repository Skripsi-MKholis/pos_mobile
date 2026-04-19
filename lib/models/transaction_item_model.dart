class TransactionItemModel {
  final String id;
  final String transactionId;
  final String? productId;
  final String productName;
  final String? productSku;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final Map<String, dynamic>? selectedVariants;
  final Map<String, dynamic>? discountApplied;
  final String? notes;
  double get price => unitPrice;

  TransactionItemModel({
    required this.id,
    required this.transactionId,
    this.productId,
    required this.productName,
    this.productSku,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.selectedVariants,
    this.discountApplied,
    this.notes,
  });

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map['id'],
      transactionId: map['transaction_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      productSku: map['product_sku'],
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'],
      subtotal: (map['subtotal'] as num).toDouble(),
      // variants and discounts would be parsed from JSON strings in SQLite
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'unit_price': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'notes': notes,
    };
  }
}
