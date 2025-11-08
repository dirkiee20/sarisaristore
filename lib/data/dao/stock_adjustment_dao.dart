import '../database/database_helper.dart';
import '../models/stock_adjustment_model.dart';

/// Data Access Object for Stock Adjustment operations
class StockAdjustmentDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new stock adjustment
  Future<int> insertStockAdjustment(StockAdjustmentModel adjustment) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'stock_adjustments',
      adjustment.toMap(),
    );
  }

  /// Get all stock adjustments
  Future<List<StockAdjustmentModel>> getAllStockAdjustments() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_adjustments',
      orderBy: 'adjusted_at DESC',
    );

    return List.generate(maps.length, (i) {
      return StockAdjustmentModel.fromMap(maps[i]);
    });
  }

  /// Get stock adjustments by product ID
  Future<List<StockAdjustmentModel>> getStockAdjustmentsByProduct(int productId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_adjustments',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'adjusted_at DESC',
    );

    return List.generate(maps.length, (i) {
      return StockAdjustmentModel.fromMap(maps[i]);
    });
  }

  /// Get stock adjustments by date range
  Future<List<StockAdjustmentModel>> getStockAdjustmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_adjustments',
      where: 'adjusted_at >= ? AND adjusted_at <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'adjusted_at DESC',
    );

    return List.generate(maps.length, (i) {
      return StockAdjustmentModel.fromMap(maps[i]);
    });
  }

  /// Get stock adjustment by ID
  Future<StockAdjustmentModel?> getStockAdjustmentById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stock_adjustments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return StockAdjustmentModel.fromMap(maps.first);
  }
}

