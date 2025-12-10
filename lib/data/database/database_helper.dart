import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

/// Database helper for SQLite database management
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sqflite.Database? _database;

  DatabaseHelper._init();

  /// Get database instance (singleton)
  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sarisari_pro.db');
    return _database!;
  }

  /// Initialize database
  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sqflite.openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create database tables
  Future<void> _createDB(sqflite.Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        barcode TEXT UNIQUE,
        cost_price REAL NOT NULL,
        selling_price REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        image_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT,
        parent_category TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_number TEXT NOT NULL UNIQUE,
        total_amount REAL NOT NULL,
        total_profit REAL NOT NULL,
        transaction_date TEXT NOT NULL,
        notes TEXT,
        payment_method TEXT,
        payment_amount REAL,
        created_at TEXT NOT NULL
      )
    ''');

    // Transaction items table
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        unit_price REAL NOT NULL,
        cost_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        profit REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Stock adjustments table
    await db.execute('''
      CREATE TABLE stock_adjustments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        previous_stock INTEGER NOT NULL,
        new_stock INTEGER NOT NULL,
        difference INTEGER NOT NULL,
        reason TEXT NOT NULL,
        notes TEXT,
        adjusted_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        expense_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db
        .execute('CREATE INDEX idx_products_category ON products(category)');
    await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions(transaction_date)');
    await db.execute(
        'CREATE INDEX idx_transaction_items_transaction ON transaction_items(transaction_id)');
    await db.execute(
        'CREATE INDEX idx_stock_adjustments_product ON stock_adjustments(product_id)');
    await db
        .execute('CREATE INDEX idx_expenses_date ON expenses(expense_date)');
  }

  /// Upgrade database
  Future<void> _upgradeDB(
      sqflite.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add payment_method and payment_amount columns to transactions table
      await db
          .execute('ALTER TABLE transactions ADD COLUMN payment_method TEXT');
      await db
          .execute('ALTER TABLE transactions ADD COLUMN payment_amount REAL');
    }
    if (oldVersion < 3) {
      // Add customer_name and customer_contact columns to transactions table
      await db
          .execute('ALTER TABLE transactions ADD COLUMN customer_name TEXT');
      await db
          .execute('ALTER TABLE transactions ADD COLUMN customer_contact TEXT');
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  /// Delete database (for testing/reset)
  Future<void> deleteDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, 'sarisari_pro.db');
    await sqflite.deleteDatabase(path);
  }
}
