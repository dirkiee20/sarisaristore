/// Category model for product categorization
class CategoryModel {
  final int? id;
  final String name;
  final String? icon;
  final String? parentCategory;
  final DateTime createdAt;

  CategoryModel({
    this.id,
    required this.name,
    this.icon,
    this.parentCategory,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'parent_category': parentCategory,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from Map (database result)
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      parentCategory: map['parent_category'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Create a copy with updated fields
  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    String? parentCategory,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      parentCategory: parentCategory ?? this.parentCategory,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, parentCategory: $parentCategory)';
  }
}

