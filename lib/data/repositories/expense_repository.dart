import '../dao/expense_dao.dart';
import '../models/expense_model.dart';

/// Repository for Expense operations
class ExpenseRepository {
  final ExpenseDao _expenseDao = ExpenseDao();

  /// Create a new expense
  Future<int> createExpense(ExpenseModel expense) async {
    return await _expenseDao.insertExpense(expense);
  }

  /// Get all expenses
  Future<List<ExpenseModel>> getAllExpenses() async {
    return await _expenseDao.getAllExpenses();
  }

  /// Get expense by ID
  Future<ExpenseModel?> getExpenseById(int id) async {
    return await _expenseDao.getExpenseById(id);
  }

  /// Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _expenseDao.getExpensesByDateRange(startDate, endDate);
  }

  /// Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    return await _expenseDao.getExpensesByCategory(category);
  }

  /// Get total expenses for a date range
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    return await _expenseDao.getTotalExpenses(startDate, endDate);
  }

  /// Get expenses grouped by category for a date range
  Future<Map<String, double>> getExpensesByCategoryGrouped(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _expenseDao.getExpensesByCategoryGrouped(startDate, endDate);
  }

  /// Update expense
  Future<int> updateExpense(ExpenseModel expense) async {
    return await _expenseDao.updateExpense(expense);
  }

  /// Delete expense
  Future<int> deleteExpense(int id) async {
    return await _expenseDao.deleteExpense(id);
  }
}

