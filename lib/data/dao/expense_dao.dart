import '../database/database_helper.dart';
import '../models/expense_model.dart';

/// Data Access Object for Expense operations
class ExpenseDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Insert a new expense
  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'expenses',
      expense.toMap(),
    );
  }

  /// Get all expenses
  Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'expense_date DESC',
    );

    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  /// Get expense by ID
  Future<ExpenseModel?> getExpenseById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ExpenseModel.fromMap(maps.first);
  }

  /// Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'expense_date >= ? AND expense_date <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'expense_date DESC',
    );

    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  /// Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'expense_date DESC',
    );

    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  /// Get total expenses for a date range
  Future<double> getTotalExpenses(DateTime startDate, DateTime endDate) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM expenses
      WHERE expense_date >= ? AND expense_date <= ?
    ''', [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get expenses grouped by category for a date range
  Future<Map<String, double>> getExpensesByCategoryGrouped(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM expenses
      WHERE expense_date >= ? AND expense_date <= ?
      GROUP BY category
      ORDER BY total DESC
    ''', [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);

    final Map<String, double> result = {};
    for (final map in maps) {
      result[map['category'] as String] = (map['total'] as num).toDouble();
    }
    return result;
  }

  /// Update expense
  Future<int> updateExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Delete expense
  Future<int> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

