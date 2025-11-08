/// Product model for the inventory management system
class ProductModel {
  final int? id;
  final String name;
  final String? description;
  final String category;
  final String? barcode;
  final double costPrice;
  final double sellingPrice;
  final int stock;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    this.id,
    required this.name,
    this.description,
    required this.category,
    this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.stock,
    this.imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Calculate profit margin percentage
  double get profitMargin {
    if (costPrice == 0) return 0;
    return ((sellingPrice - costPrice) / costPrice * 100);
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'barcode': barcode,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'stock': stock,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from Map (database result)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String,
      barcode: map['barcode'] as String?,
      costPrice: (map['cost_price'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      stock: map['stock'] as int,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create a copy with updated fields
  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? barcode,
    double? costPrice,
    double? sellingPrice,
    int? stock,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, category: $category, stock: $stock)';
  }
}

