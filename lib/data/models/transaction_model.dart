/// Transaction model for sales records
class TransactionModel {
  final int? id;
  final String transactionNumber;
  final double totalAmount;
  final double totalProfit;
  final DateTime transactionDate;
  final String? notes;
  final String? paymentMethod;
  final double? paymentAmount;
  final String? customerName;
  final String? customerContact;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    String? transactionNumber,
    required this.totalAmount,
    required this.totalProfit,
    DateTime? transactionDate,
    this.notes,
    this.paymentMethod,
    this.paymentAmount,
    this.customerName,
    this.customerContact,
    DateTime? createdAt,
  })  : transactionNumber = transactionNumber ?? _generateTransactionNumber(),
        transactionDate = transactionDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  static String _generateTransactionNumber() {
    final now = DateTime.now();
    return 'TXN-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'total_amount': totalAmount,
      'total_profit': totalProfit,
      'transaction_date': transactionDate.toIso8601String(),
      'notes': notes,
      'payment_method': paymentMethod,
      'payment_amount': paymentAmount,
      'customer_name': customerName,
      'customer_contact': customerContact,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from Map (database result)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      transactionNumber: map['transaction_number'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      totalProfit: (map['total_profit'] as num).toDouble(),
      transactionDate: DateTime.parse(map['transaction_date'] as String),
      notes: map['notes'] as String?,
      paymentMethod: map['payment_method'] as String?,
      paymentAmount: map['payment_amount'] != null
          ? (map['payment_amount'] as num).toDouble()
          : null,
      customerName: map['customer_name'] as String?,
      customerContact: map['customer_contact'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, transactionNumber: $transactionNumber, totalAmount: $totalAmount)';
  }
}
