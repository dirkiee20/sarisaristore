import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';

/// Data Access Object for Transaction operations
class TransactionDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new transaction with items
  Future<int> insertTransaction(
    TransactionModel transaction,
    List<TransactionItemModel> items,
  ) async {
    final db = await _dbHelper.database;
    
    // Use transaction for atomicity
    return await db.transaction((txn) async {
      // Insert transaction
      final transactionId = await txn.insert(
        'transactions',
        transaction.toMap(),
      );

      // Insert transaction items
      for (final item in items) {
        await txn.insert(
          'transaction_items',
          item.copyWith(id: null, transactionId: transactionId).toMap(),
        );
      }

      return transactionId;
    });
  }

  /// Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'transaction_date DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  /// Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'transaction_date >= ? AND transaction_date <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'transaction_date DESC',
    );

    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  /// Get transaction items by transaction ID
  Future<List<TransactionItemModel>> getTransactionItems(int transactionId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'id ASC',
    );

    return List.generate(maps.length, (i) {
      return TransactionItemModel.fromMap(maps[i]);
    });
  }

  /// Get total revenue for a date range
  Future<double> getTotalRevenue(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total
      FROM transactions
      WHERE transaction_date >= ? AND transaction_date <= ?
    ''', [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total profit for a date range
  Future<double> getTotalProfit(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(total_profit) as total
      FROM transactions
      WHERE transaction_date >= ? AND transaction_date <= ?
    ''', [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get transaction count for a date range
  Future<int> getTransactionCount(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM transactions
      WHERE transaction_date >= ? AND transaction_date <= ?
    ''', [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Delete transaction (cascade deletes items)
  Future<int> deleteTransaction(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

