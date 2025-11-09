import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/barcode_scanner_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/search_bar_widget.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = true;
  bool _showLowStock = false;
  bool _showHighProfit = false;
  bool _showRecentUpdates = false;

  List<ProductModel> _products = [];
  List<String> _categories = [];

  List<Map<String, dynamic>> get _filteredProducts {
    // Convert ProductModel to Map for compatibility with existing UI
    var filtered = _products
        .map((product) => {
              "id": product.id,
              "name": product.name,
              "category": product.category,
              "stock": product.stock,
              "costPrice": product.costPrice,
              "sellingPrice": "₱${product.sellingPrice.toStringAsFixed(2)}",
              "profitMargin": product.profitMargin,
              "image": product.imagePath ??
                  "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
              "semanticLabel": "${product.name} product image",
              "barcode": product.barcode,
              "description": product.description,
              "lastUpdated": product.updatedAt,
            })
        .toList();

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered
          .where((product) =>
              (product["category"] as String?) == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = (product["name"] as String?) ?? "";
        final category = (product["category"] as String?) ?? "";
        final barcode = (product["barcode"] as String?) ?? "";

        return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            barcode.contains(_searchQuery);
      }).toList();
    }

    // Apply additional filters
    if (_showLowStock) {
      filtered =
          filtered.where((product) => (product["stock"] as int) <= 10).toList();
    }

    if (_showHighProfit) {
      filtered = filtered
          .where((product) => (product["profitMargin"] as double) >= 30.0)
          .toList();
    }

    if (_showRecentUpdates) {
      final recentThreshold =
          DateTime.now().subtract(const Duration(hours: 24));
      filtered = filtered.where((product) {
        final lastUpdated = product["lastUpdated"] as DateTime;
        return lastUpdated.isAfter(recentThreshold);
      }).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productService.getAllProducts();

      // Get unique categories from real products
      final categories = products.map((p) => p.category).toSet().toList();

      setState(() {
        _products = products;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: $e'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  // Method to refresh products after purchase (called from checkout)
  void _refreshProductsAfterPurchase() {
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;
    final filteredProducts = _filteredProducts;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with title
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color:
                        isLight ? AppTheme.dividerLight : AppTheme.dividerDark,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Products',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${_filteredProducts.length} items in inventory',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isLight
                                ? AppTheme.textSecondaryLight
                                : AppTheme.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quick actions
                  Row(
                    children: [
                      IconButton(
                        onPressed: _refreshProducts,
                        icon: CustomIconWidget(
                          iconName: 'refresh',
                          color: AppTheme.primaryLight,
                          size: 24,
                        ),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            SearchBarWidget(
              controller: _searchController,
              hintText: 'Search products, categories, or barcodes...',
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onBarcodePressed: _showBarcodeScanner,
              onFilterPressed: _showFilterOptions,
            ),

            // Filter Chips
            FilterChipsWidget(
              categories: _categories
                  .map((cat) => {
                        "name": cat,
                        "count":
                            _products.where((p) => p.category == cat).length
                      })
                  .toList(),
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),

            // Products List or Empty State
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                      ? EmptyStateWidget(
                          title: _searchQuery.isNotEmpty ||
                                  _selectedCategory != null
                              ? 'No Products Found'
                              : 'Start Your Inventory',
                          subtitle: _searchQuery.isNotEmpty ||
                                  _selectedCategory != null
                              ? 'Try adjusting your search or filter criteria'
                              : 'Add your first product to start managing your sari-sari store inventory',
                          buttonText: _searchQuery.isNotEmpty ||
                                  _selectedCategory != null
                              ? 'Clear Filters'
                              : 'Add Your First Product',
                          onButtonPressed: _searchQuery.isNotEmpty ||
                                  _selectedCategory != null
                              ? _clearFilters
                              : _navigateToAddProduct,
                          illustrationUrl:
                              "https://images.pexels.com/photos/7688336/pexels-photo-7688336.jpeg?auto=compress&cs=tinysrgb&w=800",
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshProducts,
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 10.h),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCardWidget(
                                product: product,
                                onTap: () => _navigateToProductDetails(product),
                                onEdit: () => _editProduct(product),
                                onDelete: () => _deleteProduct(product),
                                onStockUpdate: () => _updateStock(product),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on Products tab
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/analytics-tab');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/stock-management-tab');
              break;
          }
        },
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        tooltip: 'Add Product',
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _refreshProducts() async {
    // Refresh real data
    await _loadProducts();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Products refreshed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showBarcodeScanner() async {
    try {
      final barcodeScanner = BarcodeScannerService();
      final scannedBarcode = await barcodeScanner.scanBarcode(context);

      if (scannedBarcode != null) {
        // Validate barcode
        if (barcodeScanner.isValidBarcode(scannedBarcode)) {
          // Search for product with this barcode
          final matchingProduct = _filteredProducts.firstWhere(
            (product) => product["barcode"] == scannedBarcode,
            orElse: () => <String, dynamic>{},
          );

          if (matchingProduct.isNotEmpty) {
            // Product found - show product details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found product: ${matchingProduct["name"]}'),
                backgroundColor: AppTheme.successLight,
                action: SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () {
                    // Could navigate to product details or highlight the product
                    setState(() {
                      _searchQuery = scannedBarcode;
                      _searchController.text = scannedBarcode;
                    });
                  },
                ),
              ),
            );
          } else {
            // Product not found - offer to add new product
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product not found for barcode: $scannedBarcode'),
                backgroundColor: AppTheme.warningLight,
                action: SnackBarAction(
                  label: 'Add Product',
                  textColor: Colors.white,
                  onPressed: () {
                    // Navigate to add product screen with pre-filled barcode
                    Navigator.pushNamed(
                      context,
                      '/add-product-screen',
                      arguments: {'barcode': scannedBarcode},
                    );
                  },
                ),
              ),
            );
          }
        } else {
          // Invalid barcode format
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid barcode format: $scannedBarcode'),
              backgroundColor: AppTheme.errorLight,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to scan barcode: $e'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
                margin: EdgeInsets.only(bottom: 3.h),
              ),
              Text(
                'Filter Options',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 2.h),
              CheckboxListTile(
                value: _showLowStock,
                onChanged: (value) {
                  setModalState(() {
                    _showLowStock = value ?? false;
                  });
                  setState(() {}); // Update parent state for filtering
                },
                title: const Text('Low Stock Items'),
                subtitle: const Text('Products with 10 or fewer items'),
                secondary: CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.errorLight,
                  size: 24,
                ),
              ),
              CheckboxListTile(
                value: _showHighProfit,
                onChanged: (value) {
                  setModalState(() {
                    _showHighProfit = value ?? false;
                  });
                  setState(() {}); // Update parent state for filtering
                },
                title: const Text('High Profit Margin'),
                subtitle: const Text('Products with 30%+ profit margin'),
                secondary: CustomIconWidget(
                  iconName: 'trending_up',
                  color: AppTheme.successLight,
                  size: 24,
                ),
              ),
              CheckboxListTile(
                value: _showRecentUpdates,
                onChanged: (value) {
                  setModalState(() {
                    _showRecentUpdates = value ?? false;
                  });
                  setState(() {}); // Update parent state for filtering
                },
                title: const Text('Recently Updated'),
                subtitle: const Text('Products updated in last 24 hours'),
                secondary: CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _showLowStock = false;
      _showHighProfit = false;
      _showRecentUpdates = false;
      _searchController.clear();
    });
  }

  void _navigateToAddProduct() {
    Navigator.pushNamed(context, '/add-product-screen');
  }

  void _navigateToProductDetails(Map<String, dynamic> product) {
    // Navigate to checkout screen with selected product
    Navigator.pushNamed(
      context,
      '/checkout',
      arguments: product,
    ).then((_) {
      // Refresh products after returning from checkout (purchase completed)
      _refreshProductsAfterPurchase();
    });
  }

  void _editProduct(Map<String, dynamic> product) {
    // Navigate to edit product screen (assuming route exists)
    Navigator.pushNamed(
      context,
      '/edit-product',
      arguments: product,
    ).then((result) {
      if (result == true) {
        // Product was updated, refresh the list
        _loadProducts();
      }
    });
  }

  void _deleteProduct(Map<String, dynamic> product) {
    // Delete from database
    final productId = product["id"] as int?;
    if (productId != null) {
      _productService.deleteProduct(productId).then((_) {
        _loadProducts(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product["name"]} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Note: Undo functionality would require more complex implementation
                // For now, just show a message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Undo not implemented for database operations'),
                  ),
                );
              },
            ),
          ),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _updateStock(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock - ${product["name"]}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current stock: ${product["stock"]} items'),
            SizedBox(height: 2.h),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New stock quantity',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) async {
                final newStock = int.tryParse(value);
                if (newStock != null) {
                  final productId = product["id"] as int?;
                  if (productId != null) {
                    try {
                      await _productService.adjustStock(
                          productId, newStock, 'Manual Adjustment');
                      Navigator.of(context).pop();
                      _loadProducts(); // Refresh the list
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Stock updated for ${product["name"]}'),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update stock: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
