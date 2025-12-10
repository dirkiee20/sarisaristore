# Class Diagram for Sarisari Store Data Models

This diagram shows the relationships between the data models in the Sarisari Store application, focusing on core relationships with multiplicities.

```mermaid
classDiagram
    class CategoryModel {
        +int? id
        +String name
        +String? icon
        +String? parentCategory
        +DateTime createdAt
        +Map<String, dynamic> toMap()
        +CategoryModel fromMap(Map<String, dynamic> map)
        +CategoryModel copyWith(...)
        +String toString()
    }
    class ProductModel {
        +int? id
        +String name
        +String? description
        +String category
        +String? barcode
        +double costPrice
        +double sellingPrice
        +int stock
        +String? imagePath
        +DateTime createdAt
        +DateTime updatedAt
        +double get profitMargin
        +Map<String, dynamic> toMap()
        +ProductModel fromMap(Map<String, dynamic> map)
        +ProductModel copyWith(...)
        +String toString()
    }
    class TransactionModel {
        +int? id
        +String transactionNumber
        +double totalAmount
        +double totalProfit
        +DateTime transactionDate
        +String? notes
        +String? paymentMethod
        +double? paymentAmount
        +DateTime createdAt
        +Map<String, dynamic> toMap()
        +TransactionModel fromMap(Map<String, dynamic> map)
        +String toString()
    }
    class TransactionItemModel {
        +int? id
        +int transactionId
        +int productId
        +String productName
        +double unitPrice
        +double costPrice
        +int quantity
        +double subtotal
        +double profit
        +Map<String, dynamic> toMap()
        +TransactionItemModel fromMap(Map<String, dynamic> map)
        +TransactionItemModel copyWith(...)
        +String toString()
    }
    class StockAdjustmentModel {
        +int? id
        +int productId
        +String productName
        +int previousStock
        +int newStock
        +int difference
        +String reason
        +String? notes
        +DateTime adjustedAt
        +DateTime createdAt
        +Map<String, dynamic> toMap()
        +StockAdjustmentModel fromMap(Map<String, dynamic> map)
        +String toString()
    }
    class ExpenseModel {
        +int? id
        +String category
        +double amount
        +String? description
        +DateTime expenseDate
        +DateTime createdAt
        +Map<String, dynamic> toMap()
        +ExpenseModel fromMap(Map<String, dynamic> map)
        +ExpenseModel copyWith(...)
        +String toString()
    }
    class ProductService {
        +ProductRepository _productRepository
        +StockAdjustmentRepository _stockAdjustmentRepository
        +Future<int> createProduct(ProductModel product)
        +Future<int> updateProduct(ProductModel product)
        +Future<void> adjustStock(int productId, int newStock, String reason)
        +Future<List<ProductModel>> getAllProducts()
        +Future<ProductModel?> getProductById(int id)
        +Future<int> deleteProduct(int id)
    }
    class ProductRepository {
        +ProductDao _productDao
        +Future<int> createProduct(ProductModel product)
        +Future<List<ProductModel>> getAllProducts()
        +Future<ProductModel?> getProductById(int id)
        +Future<int> updateProduct(ProductModel product)
        +Future<int> updateProductStock(int productId, int newStock)
        +Future<int> deleteProduct(int id)
    }
    class ProductDao {
        +DatabaseHelper _dbHelper
        +Future<int> insertProduct(ProductModel product)
        +Future<List<ProductModel>> getAllProducts()
        +Future<ProductModel?> getProductById(int id)
        +Future<int> updateProduct(ProductModel product)
        +Future<int> updateProductStock(int productId, int newStock)
        +Future<int> deleteProduct(int id)
    }
    class TransactionService {
        +TransactionRepository _transactionRepository
        +ProductRepository _productRepository
        +Future<int> createTransaction(List<Map<String, dynamic>> items)
        +Future<List<TransactionModel>> getAllTransactions()
        +Future<TransactionModel?> getTransactionById(int id)
        +Future<List<TransactionItemModel>> getTransactionItems(int transactionId)
        +Future<int> deleteTransaction(int id)
    }
    class TransactionRepository {
        +TransactionDao _transactionDao
        +Future<int> createTransaction(TransactionModel transaction, List<TransactionItemModel> items)
        +Future<List<TransactionModel>> getAllTransactions()
        +Future<TransactionModel?> getTransactionById(int id)
        +Future<List<TransactionItemModel>> getTransactionItems(int transactionId)
        +Future<int> deleteTransaction(int id)
    }
    class TransactionDao {
        +DatabaseHelper _dbHelper
        +Future<int> insertTransaction(TransactionModel transaction, List<TransactionItemModel> items)
        +Future<List<TransactionModel>> getAllTransactions()
        +Future<TransactionModel?> getTransactionById(int id)
        +Future<List<TransactionItemModel>> getTransactionItems(int transactionId)
        +Future<int> deleteTransaction(int id)
    }
    class DatabaseHelper {
        -static DatabaseHelper instance
        -static Database _database
        +Future<Database> get database
        +Future<Database> _initDB(String filePath)
        +Future<void> _createDB(Database db, int version)
        +Future<void> _upgradeDB(Database db, int oldVersion, int newVersion)
        +Future<void> close()
        +Future<void> deleteDatabase()
    }

    CategoryModel "1" --> "0..*" ProductModel : 1 to many (categorizes)
    CategoryModel "1" --> "0..*" ExpenseModel : 1 to many (categorizes)
    CategoryModel "0..1" --> "0..*" CategoryModel : 0..1 to many (parent)
    ProductModel "1" --> "0..*" StockAdjustmentModel : 1 to many (adjusts)
    ProductModel "1" --> "0..*" TransactionItemModel : 1 to many (sold in)
    TransactionModel "1" --> "1..*" TransactionItemModel : 1 to many (contains)

    ProductService --> ProductRepository : uses
    ProductRepository --> ProductDao : uses
    ProductDao --> DatabaseHelper : uses
    ProductDao --> ProductModel : operates on
    ProductDao --> StockAdjustmentModel : operates on
    TransactionService --> TransactionRepository : uses
    TransactionService --> ProductRepository : uses
    TransactionRepository --> TransactionDao : uses
    TransactionDao --> DatabaseHelper : uses
    TransactionDao --> TransactionModel : operates on
    TransactionDao --> TransactionItemModel : operates on