/// Transaction item model for individual items in a transaction
class TransactionItemModel {
  final int? id;
  final int transactionId;
  final int productId;
  final String productName;
  final double unitPrice;
  final double costPrice;
  final int quantity;
  final double subtotal;
  final double profit;

  TransactionItemModel({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.costPrice,
    required this.quantity,
    required this.subtotal,
    required this.profit,
  });

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'profit': profit,
    };
  }

  /// Create from Map (database result)
  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      subtotal: (map['subtotal'] as num).toDouble(),
      profit: (map['profit'] as num).toDouble(),
    );
  }

  /// Create a copy with updated fields
  TransactionItemModel copyWith({
    int? id,
    int? transactionId,
    int? productId,
    String? productName,
    double? unitPrice,
    double? costPrice,
    int? quantity,
    double? subtotal,
    double? profit,
  }) {
    return TransactionItemModel(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      profit: profit ?? this.profit,
    );
  }

  @override
  String toString() {
    return 'TransactionItemModel(id: $id, productName: $productName, quantity: $quantity, subtotal: $subtotal)';
  }
}

