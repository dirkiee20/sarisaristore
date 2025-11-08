import '../dao/category_dao.dart';
import '../models/category_model.dart';

/// Repository for Category operations
class CategoryRepository {
  final CategoryDao _categoryDao = CategoryDao();

  /// Create a new category
  Future<int> createCategory(CategoryModel category) async {
    return await _categoryDao.insertCategory(category);
  }

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    return await _categoryDao.getAllCategories();
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(int id) async {
    return await _categoryDao.getCategoryById(id);
  }

  /// Get categories by parent
  Future<List<CategoryModel>> getCategoriesByParent(String? parentCategory) async {
    return await _categoryDao.getCategoriesByParent(parentCategory);
  }

  /// Delete category
  Future<int> deleteCategory(int id) async {
    return await _categoryDao.deleteCategory(id);
  }

  /// Initialize default categories
  Future<void> initializeDefaultCategories() async {
    return await _categoryDao.initializeDefaultCategories();
  }
}

