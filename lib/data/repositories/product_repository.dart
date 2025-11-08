import '../dao/product_dao.dart';
import '../models/product_model.dart';

/// Repository for Product operations
class ProductRepository {
  final ProductDao _productDao = ProductDao();

  /// Create a new product
  Future<int> createProduct(ProductModel product) async {
    return await _productDao.insertProduct(product);
  }

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    return await _productDao.getAllProducts();
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(int id) async {
    return await _productDao.getProductById(id);
  }

  /// Get product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    return await _productDao.getProductByBarcode(barcode);
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    return await _productDao.getProductsByCategory(category);
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    return await _productDao.searchProducts(query);
  }

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts({int threshold = 10}) async {
    return await _productDao.getLowStockProducts(threshold: threshold);
  }

  /// Update product
  Future<int> updateProduct(ProductModel product) async {
    return await _productDao.updateProduct(product);
  }

  /// Update product stock
  Future<int> updateProductStock(int productId, int newStock) async {
    return await _productDao.updateProductStock(productId, newStock);
  }

  /// Delete product
  Future<int> deleteProduct(int id) async {
    return await _productDao.deleteProduct(id);
  }

  /// Get product count
  Future<int> getProductCount() async {
    return await _productDao.getProductCount();
  }

  /// Get product count by category
  Future<int> getProductCountByCategory(String category) async {
    return await _productDao.getProductCountByCategory(category);
  }
}

