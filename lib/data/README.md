# Backend Architecture

This directory contains the backend implementation for the SariSari Pro inventory management application using SQLite as the local database.

## Architecture Overview

The backend follows a layered architecture:

```
lib/data/
├── models/          # Data models (Product, Category, Transaction, etc.)
├── database/         # Database setup and initialization
├── dao/             # Data Access Objects (database operations)
└── repositories/    # Repository layer (data access abstraction)

lib/services/        # Business logic layer
```

## Database

**SQLite** is used as the local database for this standalone mobile application. The database file is stored locally on the device.

### Database Schema

- **products**: Product inventory data
- **categories**: Product categories
- **transactions**: Sales transactions
- **transaction_items**: Individual items in transactions
- **stock_adjustments**: Stock adjustment history
- **expenses**: Business expenses

## Usage

### 1. Initialize Database

```dart
import 'package:sarisari_pro/data/database/database_initializer.dart';

final initializer = DatabaseInitializer();
await initializer.initialize();
```

### 2. Using Services

#### Product Service

```dart
import 'package:sarisari_pro/services/product_service.dart';

final productService = ProductService();

// Create a product
final product = ProductModel(
  name: 'Coca-Cola 330ml',
  category: 'Beverages',
  costPrice: 15.00,
  sellingPrice: 20.00,
  stock: 45,
  barcode: '1234567890123',
);
await productService.createProduct(product);

// Get all products
final products = await productService.getAllProducts();

// Search products
final results = await productService.searchProducts('Coca');

// Adjust stock
await productService.adjustStock(
  productId: 1,
  newStock: 50,
  reason: 'Manual Adjustment',
);
```

#### Transaction Service

```dart
import 'package:sarisari_pro/services/transaction_service.dart';

final transactionService = TransactionService();

// Create a transaction
final transactionId = await transactionService.createTransaction(
  [
    {'productId': 1, 'quantity': 2},
    {'productId': 2, 'quantity': 1},
  ],
  notes: 'Customer purchase',
);

// Get transactions for a date range
final startDate = DateTime(2024, 1, 1);
final endDate = DateTime(2024, 1, 31);
final transactions = await transactionService.getTransactionsByDateRange(
  startDate,
  endDate,
);
```

#### Analytics Service

```dart
import 'package:sarisari_pro/services/analytics_service.dart';

final analyticsService = AnalyticsService();

// Get revenue for a period
final revenue = await analyticsService.getRevenueForPeriod('Today');

// Get profit trends
final trends = await analyticsService.getProfitTrendsForPeriod('Week');

// Get top products
final topProducts = await analyticsService.getTopProductsForPeriod('Month');
```

#### Expense Service

```dart
import 'package:sarisari_pro/services/expense_service.dart';
import 'package:sarisari_pro/data/models/expense_model.dart';

final expenseService = ExpenseService();

// Create an expense
final expense = ExpenseModel(
  category: 'Utilities',
  amount: 500.00,
  description: 'Electricity bill',
);
await expenseService.createExpense(expense);
```

## Data Models

All models are located in `lib/data/models/`:

- `ProductModel`: Product information
- `CategoryModel`: Product categories
- `TransactionModel`: Sales transactions
- `TransactionItemModel`: Items in a transaction
- `StockAdjustmentModel`: Stock adjustment records
- `ExpenseModel`: Business expenses

## Notes

- The database is automatically created on first use
- Default categories are initialized automatically
- All database operations are asynchronous
- Transactions are atomic (all or nothing)
- Stock is automatically updated when transactions are created
- Stock adjustments are tracked with history

