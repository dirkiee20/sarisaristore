import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/product_model.dart';

/// Data Access Object for Product operations
class ProductDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new product
  Future<int> insertProduct(ProductModel product) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return ProductModel.fromMap(maps[i]);
    });
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  /// Get product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return ProductModel.fromMap(maps[i]);
    });
  }

  /// Search products by name, category, or barcode
  Future<List<ProductModel>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final searchQuery = '%$query%';
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? OR category LIKE ? OR barcode LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return ProductModel.fromMap(maps[i]);
    });
  }

  /// Get low stock products (stock <= threshold)
  Future<List<ProductModel>> getLowStockProducts({int threshold = 10}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'stock <= ?',
      whereArgs: [threshold],
      orderBy: 'stock ASC',
    );

    return List.generate(maps.length, (i) {
      return ProductModel.fromMap(maps[i]);
    });
  }

  /// Update product
  Future<int> updateProduct(ProductModel product) async {
    final db = await _dbHelper.database;
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());
    return await db.update(
      'products',
      updatedProduct.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// Update product stock
  Future<int> updateProductStock(int productId, int newStock) async {
    final db = await _dbHelper.database;
    return await db.update(
      'products',
      {
        'stock': newStock,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  /// Delete product
  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get product count
  Future<int> getProductCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get product count by category
  Future<int> getProductCountByCategory(String category) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE category = ?',
      [category],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

