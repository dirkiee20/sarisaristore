import '../data/repositories/transaction_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/expense_repository.dart';

/// Service for Analytics business logic
class AnalyticsService {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final ProductRepository _productRepository = ProductRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  /// Get date range for period
  Map<String, DateTime> _getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
        break;
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate =
            DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1, 0, 0, 0);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1, 0, 0, 0);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    }

    return {'start': startDate, 'end': endDate};
  }

  /// Get revenue for period
  Future<double> getRevenueForPeriod(String period) async {
    final dateRange = _getDateRangeForPeriod(period);
    return await _transactionRepository.getTotalRevenue(
      dateRange['start']!,
      dateRange['end']!,
    );
  }

  /// Get profit for period
  Future<double> getProfitForPeriod(String period) async {
    final dateRange = _getDateRangeForPeriod(period);
    return await _transactionRepository.getTotalProfit(
      dateRange['start']!,
      dateRange['end']!,
    );
  }

  /// Get expenses for period (cost of products ordered)
  Future<double> getExpensesForPeriod(String period) async {
    final dateRange = _getDateRangeForPeriod(period);

    // Get all transactions for the period
    final transactions =
        await _transactionRepository.getTransactionsByDateRange(
      dateRange['start']!,
      dateRange['end']!,
    );

    // Calculate total cost of products ordered
    double totalCost = 0.0;
    for (final transaction in transactions) {
      final items =
          await _transactionRepository.getTransactionItems(transaction.id!);
      for (final item in items) {
        totalCost += item.costPrice * item.quantity;
      }
    }

    return totalCost;
  }

  /// Get business expenses for period (additional expenses like rent, utilities, etc.)
  Future<double> getBusinessExpensesForPeriod(String period) async {
    final dateRange = _getDateRangeForPeriod(period);
    return await _expenseRepository.getTotalExpenses(
      dateRange['start']!,
      dateRange['end']!,
    );
  }

  /// Get net income for period (includes both product costs and business expenses)
  Future<double> getNetIncomeForPeriod(String period) async {
    final profit = await getProfitForPeriod(period);
    final productCosts =
        await getExpensesForPeriod(period); // Cost of products sold
    final businessExpenses = await getBusinessExpensesForPeriod(
        period); // Additional business expenses
    return profit - productCosts - businessExpenses;
  }

  /// Get transaction count for period
  Future<int> getTransactionCountForPeriod(String period) async {
    final dateRange = _getDateRangeForPeriod(period);
    return await _transactionRepository.getTransactionCount(
      dateRange['start']!,
      dateRange['end']!,
    );
  }

  /// Get profit margin percentage for period
  Future<double> getProfitMarginForPeriod(String period) async {
    final revenue = await getRevenueForPeriod(period);
    final profit = await getProfitForPeriod(period);
    if (revenue == 0) return 0;
    return (profit / revenue) * 100;
  }

  /// Get profit trends for period (daily/weekly/monthly)
  Future<List<Map<String, dynamic>>> getProfitTrendsForPeriod(
      String period) async {
    final dateRange = _getDateRangeForPeriod(period);
    final transactions =
        await _transactionRepository.getTransactionsByDateRange(
      dateRange['start']!,
      dateRange['end']!,
    );

    // Group by date and calculate daily profit
    final Map<String, double> dailyProfit = {};
    for (final transaction in transactions) {
      final dateKey = _getDateKey(transaction.transactionDate, period);
      dailyProfit[dateKey] =
          (dailyProfit[dateKey] ?? 0) + transaction.totalProfit;
    }

    // Convert to list format
    final List<Map<String, dynamic>> trends = [];
    dailyProfit.forEach((key, value) {
      trends.add({'label': key, 'value': value});
    });

    // Sort by date
    trends.sort((a, b) => a['label'].compareTo(b['label']));

    return trends;
  }

  /// Get date key for grouping
  String _getDateKey(DateTime date, String period) {
    switch (period) {
      case 'Today':
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      case 'Week':
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[date.weekday - 1];
      case 'Month':
        final weekNumber = ((date.day - 1) ~/ 7) + 1;
        return 'Week $weekNumber';
      case 'Year':
        final quarter = ((date.month - 1) ~/ 3) + 1;
        return 'Q$quarter';
      default:
        return date.toString().substring(0, 10);
    }
  }

  /// Get top products by quantity sold for period
  Future<List<Map<String, dynamic>>> getTopProductsForPeriod(
      String period) async {
    final dateRange = _getDateRangeForPeriod(period);
    final transactions =
        await _transactionRepository.getTransactionsByDateRange(
      dateRange['start']!,
      dateRange['end']!,
    );

    // Aggregate product quantities
    final Map<String, double> productQuantities = {};
    for (final transaction in transactions) {
      final items =
          await _transactionRepository.getTransactionItems(transaction.id!);
      for (final item in items) {
        productQuantities[item.productName] =
            (productQuantities[item.productName] ?? 0) + item.quantity;
      }
    }

    // Convert to list and sort
    final List<Map<String, dynamic>> topProducts = [];
    productQuantities.forEach((name, quantity) {
      topProducts.add({'name': name, 'quantity': quantity});
    });

    topProducts.sort(
        (a, b) => (b['quantity'] as double).compareTo(a['quantity'] as double));

    return topProducts.take(5).toList();
  }

  /// Get expenses grouped by category for period (product costs by category)
  Future<Map<String, double>> getExpensesByCategoryForPeriod(
      String period) async {
    final dateRange = _getDateRangeForPeriod(period);

    // Get all transactions for the period
    final transactions =
        await _transactionRepository.getTransactionsByDateRange(
      dateRange['start']!,
      dateRange['end']!,
    );

    // Group costs by product category
    final Map<String, double> categoryCosts = {};
    for (final transaction in transactions) {
      final items =
          await _transactionRepository.getTransactionItems(transaction.id!);
      for (final item in items) {
        // Get product to determine category
        final product = await _productRepository.getProductById(item.productId);
        if (product != null) {
          final category = product.category;
          final cost = item.costPrice * item.quantity;
          categoryCosts[category] = (categoryCosts[category] ?? 0) + cost;
        }
      }
    }

    return categoryCosts;
  }

  /// Get low stock products count
  Future<int> getLowStockProductsCount({int threshold = 10}) async {
    final products =
        await _productRepository.getLowStockProducts(threshold: threshold);
    return products.length;
  }

  /// Get payment method statistics for period
  Future<Map<String, int>> getPaymentMethodStatsForPeriod(String period) async {
    final dateRange = _getDateRangeForPeriod(period);
    final transactions =
        await _transactionRepository.getTransactionsByDateRange(
      dateRange['start']!,
      dateRange['end']!,
    );

    // Count transactions by payment method
    final Map<String, int> paymentStats = {};
    for (final transaction in transactions) {
      final method = transaction.paymentMethod ?? 'Unknown';
      paymentStats[method] = (paymentStats[method] ?? 0) + 1;
    }

    return paymentStats;
  }

  /// Get payment method amounts for period (cumulative amounts by payment method)
  Future<Map<String, double>> getPaymentMethodAmountsForPeriod(
      String period) async {
    final dateRange = _getDateRangeForPeriod(period);
    final transactions =
        await _transactionRepository.getTransactionsByDateRange(
      dateRange['start']!,
      dateRange['end']!,
    );

    // Sum amounts by payment method (use totalAmount, not paymentAmount to avoid including change)
    final Map<String, double> paymentAmounts = {};
    for (final transaction in transactions) {
      final method = transaction.paymentMethod ?? 'Unknown';
      final amount = transaction
          .totalAmount; // Use actual transaction value, not amount paid
      paymentAmounts[method] = (paymentAmounts[method] ?? 0) + amount;
    }

    return paymentAmounts;
  }
}
