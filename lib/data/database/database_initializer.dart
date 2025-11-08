import '../database/database_helper.dart';
import '../repositories/category_repository.dart';

/// Database initializer for setting up default data
class DatabaseInitializer {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CategoryRepository _categoryRepository = CategoryRepository();

  /// Initialize database with default data
  Future<void> initialize() async {
    // Ensure database is created
    await _dbHelper.database;

    // Initialize default categories
    await _categoryRepository.initializeDefaultCategories();
  }

  /// Check if database is initialized
  Future<bool> isInitialized() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM categories',
    );
    final count = result.first['count'] as int? ?? 0;
    return count > 0;
  }
}

