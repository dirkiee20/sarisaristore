/// Expense model for tracking business expenses
class ExpenseModel {
  final int? id;
  final String category;
  final double amount;
  final String? description;
  final DateTime expenseDate;
  final DateTime createdAt;

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    this.description,
    DateTime? expenseDate,
    DateTime? createdAt,
  })  : expenseDate = expenseDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'expense_date': expenseDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from Map (database result)
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      expenseDate: DateTime.parse(map['expense_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Create a copy with updated fields
  ExpenseModel copyWith({
    int? id,
    String? category,
    double? amount,
    String? description,
    DateTime? expenseDate,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, category: $category, amount: $amount)';
  }
}

