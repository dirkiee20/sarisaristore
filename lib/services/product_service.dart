import '../data/repositories/product_repository.dart';
import '../data/repositories/stock_adjustment_repository.dart';
import '../data/models/product_model.dart';
import '../data/models/stock_adjustment_model.dart';

/// Service for Product business logic
class ProductService {
  final ProductRepository _productRepository = ProductRepository();
  final StockAdjustmentRepository _stockAdjustmentRepository = StockAdjustmentRepository();

  /// Create a new product
  Future<int> createProduct(ProductModel product) async {
    // Validate product data
    if (product.name.isEmpty) {
      throw Exception('Product name is required');
    }
    if (product.costPrice <= 0) {
      throw Exception('Cost price must be greater than 0');
    }
    if (product.sellingPrice <= 0) {
      throw Exception('Selling price must be greater than 0');
    }
    if (product.sellingPrice < product.costPrice) {
      throw Exception('Selling price should be higher than cost price');
    }
    if (product.stock < 0) {
      throw Exception('Stock cannot be negative');
    }

    return await _productRepository.createProduct(product);
  }

  /// Update product
  Future<int> updateProduct(ProductModel product) async {
    if (product.id == null) {
      throw Exception('Product ID is required for update');
    }

    // Validate product data
    if (product.name.isEmpty) {
      throw Exception('Product name is required');
    }
    if (product.costPrice <= 0) {
      throw Exception('Cost price must be greater than 0');
    }
    if (product.sellingPrice <= 0) {
      throw Exception('Selling price must be greater than 0');
    }
    if (product.sellingPrice < product.costPrice) {
      throw Exception('Selling price should be higher than cost price');
    }

    return await _productRepository.updateProduct(product);
  }

  /// Adjust product stock with history tracking
  Future<void> adjustStock(
    int productId,
    int newStock,
    String reason, {
    String? notes,
  }) async {
    final product = await _productRepository.getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final previousStock = product.stock;

    // Update product stock
    await _productRepository.updateProductStock(productId, newStock);

    // Create stock adjustment record
    final adjustment = StockAdjustmentModel(
      productId: productId,
      productName: product.name,
      previousStock: previousStock,
      newStock: newStock,
      reason: reason,
      notes: notes,
    );

    await _stockAdjustmentRepository.createStockAdjustment(adjustment);
  }

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    return await _productRepository.getAllProducts();
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(int id) async {
    return await _productRepository.getProductById(id);
  }

  /// Get product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    return await _productRepository.getProductByBarcode(barcode);
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    return await _productRepository.getProductsByCategory(category);
  }

  /// Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    return await _productRepository.searchProducts(query);
  }

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts({int threshold = 10}) async {
    return await _productRepository.getLowStockProducts(threshold: threshold);
  }

  /// Delete product
  Future<int> deleteProduct(int id) async {
    return await _productRepository.deleteProduct(id);
  }

  /// Get product count
  Future<int> getProductCount() async {
    return await _productRepository.getProductCount();
  }

  /// Get product count by category
  Future<int> getProductCountByCategory(String category) async {
    return await _productRepository.getProductCountByCategory(category);
  }
}

