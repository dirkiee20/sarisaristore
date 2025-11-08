import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';

/// Data Access Object for Category operations
class CategoryDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new category
  Future<int> insertCategory(CategoryModel category) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]);
    });
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  /// Get categories by parent
  Future<List<CategoryModel>> getCategoriesByParent(String? parentCategory) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: parentCategory == null ? 'parent_category IS NULL' : 'parent_category = ?',
      whereArgs: parentCategory == null ? null : [parentCategory],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]);
    });
  }

  /// Delete category
  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Initialize default categories
  Future<void> initializeDefaultCategories() async {
    final db = await _dbHelper.database;
    
    // Check if categories already exist
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) as count FROM categories'),
    ) ?? 0;

    if (count > 0) return; // Categories already initialized

    final defaultCategories = [
      CategoryModel(name: 'Food & Beverages', icon: 'restaurant'),
      CategoryModel(name: 'Personal Care', icon: 'face'),
      CategoryModel(name: 'Household Items', icon: 'home'),
      CategoryModel(name: 'School & Office', icon: 'school'),
      CategoryModel(name: 'Electronics', icon: 'electrical_services'),
      CategoryModel(name: 'Clothing', icon: 'checkroom'),
      CategoryModel(name: 'Medicine', icon: 'medical_services'),
    ];

    final batch = db.batch();
    for (final category in defaultCategories) {
      batch.insert('categories', category.toMap());
    }
    await batch.commit(noResult: true);
  }
}

