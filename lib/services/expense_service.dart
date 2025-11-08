import '../data/repositories/expense_repository.dart';
import '../data/models/expense_model.dart';

/// Service for Expense business logic
class ExpenseService {
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  /// Create a new expense
  Future<int> createExpense(ExpenseModel expense) async {
    // Validate expense data
    if (expense.category.isEmpty) {
      throw Exception('Expense category is required');
    }
    if (expense.amount <= 0) {
      throw Exception('Expense amount must be greater than 0');
    }

    return await _expenseRepository.createExpense(expense);
  }

  /// Get all expenses
  Future<List<ExpenseModel>> getAllExpenses() async {
    return await _expenseRepository.getAllExpenses();
  }

  /// Get expense by ID
  Future<ExpenseModel?> getExpenseById(int id) async {
    return await _expenseRepository.getExpenseById(id);
  }

  /// Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _expenseRepository.getExpensesByDateRange(startDate, endDate);
  }

  /// Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    return await _expenseRepository.getExpensesByCategory(category);
  }

  /// Get total expenses for a date range
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    return await _expenseRepository.getTotalExpenses(startDate, endDate);
  }

  /// Get expenses grouped by category for a date range
  Future<Map<String, double>> getExpensesByCategoryGrouped(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _expenseRepository.getExpensesByCategoryGrouped(startDate, endDate);
  }

  /// Update expense
  Future<int> updateExpense(ExpenseModel expense) async {
    if (expense.id == null) {
      throw Exception('Expense ID is required for update');
    }

    // Validate expense data
    if (expense.category.isEmpty) {
      throw Exception('Expense category is required');
    }
    if (expense.amount <= 0) {
      throw Exception('Expense amount must be greater than 0');
    }

    return await _expenseRepository.updateExpense(expense);
  }

  /// Delete expense
  Future<int> deleteExpense(int id) async {
    return await _expenseRepository.deleteExpense(id);
  }
}

