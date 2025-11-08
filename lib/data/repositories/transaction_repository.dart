import '../dao/transaction_dao.dart';
import '../models/transaction_model.dart';
import '../models/transaction_item_model.dart';

/// Repository for Transaction operations
class TransactionRepository {
  final TransactionDao _transactionDao = TransactionDao();

  /// Create a new transaction with items
  Future<int> createTransaction(
    TransactionModel transaction,
    List<TransactionItemModel> items,
  ) async {
    return await _transactionDao.insertTransaction(transaction, items);
  }

  /// Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    return await _transactionDao.getAllTransactions();
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    return await _transactionDao.getTransactionById(id);
  }

  /// Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _transactionDao.getTransactionsByDateRange(startDate, endDate);
  }

  /// Get transaction items by transaction ID
  Future<List<TransactionItemModel>> getTransactionItems(int transactionId) async {
    return await _transactionDao.getTransactionItems(transactionId);
  }

  /// Get total revenue for a date range
  Future<double> getTotalRevenue(DateTime startDate, DateTime endDate) async {
    return await _transactionDao.getTotalRevenue(startDate, endDate);
  }

  /// Get total profit for a date range
  Future<double> getTotalProfit(DateTime startDate, DateTime endDate) async {
    return await _transactionDao.getTotalProfit(startDate, endDate);
  }

  /// Get transaction count for a date range
  Future<int> getTransactionCount(DateTime startDate, DateTime endDate) async {
    return await _transactionDao.getTransactionCount(startDate, endDate);
  }

  /// Delete transaction
  Future<int> deleteTransaction(int id) async {
    return await _transactionDao.deleteTransaction(id);
  }
}

