import '../dao/stock_adjustment_dao.dart';
import '../models/stock_adjustment_model.dart';

/// Repository for Stock Adjustment operations
class StockAdjustmentRepository {
  final StockAdjustmentDao _stockAdjustmentDao = StockAdjustmentDao();

  /// Create a new stock adjustment
  Future<int> createStockAdjustment(StockAdjustmentModel adjustment) async {
    return await _stockAdjustmentDao.insertStockAdjustment(adjustment);
  }

  /// Get all stock adjustments
  Future<List<StockAdjustmentModel>> getAllStockAdjustments() async {
    return await _stockAdjustmentDao.getAllStockAdjustments();
  }

  /// Get stock adjustments by product ID
  Future<List<StockAdjustmentModel>> getStockAdjustmentsByProduct(int productId) async {
    return await _stockAdjustmentDao.getStockAdjustmentsByProduct(productId);
  }

  /// Get stock adjustments by date range
  Future<List<StockAdjustmentModel>> getStockAdjustmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _stockAdjustmentDao.getStockAdjustmentsByDateRange(startDate, endDate);
  }

  /// Get stock adjustment by ID
  Future<StockAdjustmentModel?> getStockAdjustmentById(int id) async {
    return await _stockAdjustmentDao.getStockAdjustmentById(id);
  }
}

