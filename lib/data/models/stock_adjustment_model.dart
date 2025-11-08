/// Stock adjustment model for inventory changes
class StockAdjustmentModel {
  final int? id;
  final int productId;
  final String productName;
  final int previousStock;
  final int newStock;
  final int difference;
  final String reason;
  final String? notes;
  final DateTime adjustedAt;
  final DateTime createdAt;

  StockAdjustmentModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.previousStock,
    required this.newStock,
    required this.reason,
    this.notes,
    DateTime? adjustedAt,
    DateTime? createdAt,
  })  : difference = newStock - previousStock,
        adjustedAt = adjustedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'previous_stock': previousStock,
      'new_stock': newStock,
      'difference': difference,
      'reason': reason,
      'notes': notes,
      'adjusted_at': adjustedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from Map (database result)
  factory StockAdjustmentModel.fromMap(Map<String, dynamic> map) {
    return StockAdjustmentModel(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      previousStock: map['previous_stock'] as int,
      newStock: map['new_stock'] as int,
      reason: map['reason'] as String,
      notes: map['notes'] as String?,
      adjustedAt: DateTime.parse(map['adjusted_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() {
    return 'StockAdjustmentModel(id: $id, productName: $productName, difference: $difference, reason: $reason)';
  }
}

