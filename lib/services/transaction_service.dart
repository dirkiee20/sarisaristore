import '../data/repositories/transaction_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/models/transaction_model.dart';
import '../data/models/transaction_item_model.dart';

/// Service for Transaction business logic
class TransactionService {
  final TransactionRepository _transactionRepository = TransactionRepository();
  final ProductRepository _productRepository = ProductRepository();

  /// Create a new transaction with items
  Future<int> createTransaction(
    List<Map<String, dynamic>> items, {
    String? notes,
  }) async {
    if (items.isEmpty) {
      throw Exception('Transaction must have at least one item');
    }

    double totalAmount = 0;
    double totalProfit = 0;
    final List<TransactionItemModel> transactionItems = [];

    // Process each item
    for (final item in items) {
      final productId = item['productId'] as int;
      final quantity = item['quantity'] as int;

      if (quantity <= 0) {
        throw Exception('Quantity must be greater than 0');
      }

      // Get product details
      final product = await _productRepository.getProductById(productId);
      if (product == null) {
        throw Exception('Product not found: $productId');
      }

      // Check stock availability
      if (product.stock < quantity) {
        throw Exception('Insufficient stock for ${product.name}. Available: ${product.stock}, Requested: $quantity');
      }

      // Calculate item totals
      final unitPrice = product.sellingPrice;
      final costPrice = product.costPrice;
      final subtotal = unitPrice * quantity;
      final profit = (unitPrice - costPrice) * quantity;

      totalAmount += subtotal;
      totalProfit += profit;

      // Create transaction item (transactionId will be set after transaction is created)
      transactionItems.add(TransactionItemModel(
        transactionId: 0, // Will be updated after transaction creation
        productId: productId,
        productName: product.name,
        unitPrice: unitPrice,
        costPrice: costPrice,
        quantity: quantity,
        subtotal: subtotal,
        profit: profit,
      ));
    }

    // Create transaction
    final transaction = TransactionModel(
      totalAmount: totalAmount,
      totalProfit: totalProfit,
      notes: notes,
    );

    // Insert transaction and items
    final transactionId = await _transactionRepository.createTransaction(
      transaction,
      transactionItems,
    );

    // Update product stocks
    for (final item in items) {
      final productId = item['productId'] as int;
      final quantity = item['quantity'] as int;
      final product = await _productRepository.getProductById(productId);
      if (product != null) {
        final newStock = product.stock - quantity;
        await _productRepository.updateProductStock(productId, newStock);
      }
    }

    return transactionId;
  }

  /// Get all transactions
  Future<List<TransactionModel>> getAllTransactions() async {
    return await _transactionRepository.getAllTransactions();
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    return await _transactionRepository.getTransactionById(id);
  }

  /// Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _transactionRepository.getTransactionsByDateRange(startDate, endDate);
  }

  /// Get transaction items by transaction ID
  Future<List<TransactionItemModel>> getTransactionItems(int transactionId) async {
    return await _transactionRepository.getTransactionItems(transactionId);
  }

  /// Get total revenue for a date range
  Future<double> getTotalRevenue(DateTime startDate, DateTime endDate) async {
    return await _transactionRepository.getTotalRevenue(startDate, endDate);
  }

  /// Get total profit for a date range
  Future<double> getTotalProfit(DateTime startDate, DateTime endDate) async {
    return await _transactionRepository.getTotalProfit(startDate, endDate);
  }

  /// Get transaction count for a date range
  Future<int> getTransactionCount(DateTime startDate, DateTime endDate) async {
    return await _transactionRepository.getTransactionCount(startDate, endDate);
  }

  /// Delete transaction (with stock restoration)
  Future<int> deleteTransaction(int id) async {
    // Get transaction items
    final items = await _transactionRepository.getTransactionItems(id);

    // Restore product stocks
    for (final item in items) {
      final product = await _productRepository.getProductById(item.productId);
      if (product != null) {
        final newStock = product.stock + item.quantity;
        await _productRepository.updateProductStock(item.productId, newStock);
      }
    }

    // Delete transaction
    return await _transactionRepository.deleteTransaction(id);
  }
}

