import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/product_model.dart';
import '../../services/product_service.dart';
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
  bool _isDemoMode = false;
  bool _showLowStock = false;
  bool _showHighProfit = false;
  bool _showRecentUpdates = false;

  List<ProductModel> _products = [];
  List<String> _categories = [];

  // Demo data for products (used when no real data exists)
  final List<Map<String, dynamic>> _demoProducts = [
    {
      "id": 1,
      "name": "Coca-Cola 330ml",
      "category": "Beverages",
      "stock": 45,
      "costPrice": 15.00,
      "sellingPrice": "₱20.00",
      "profitMargin": 33.3,
      "image": "https://images.unsplash.com/photo-1675599591199-7bced32f7f97",
      "semanticLabel":
          "Red Coca-Cola can with classic logo on white background",
      "barcode": "1234567890123",
      "description": "Classic Coca-Cola soft drink in 330ml can",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": 2,
      "name": "Lucky Me Pancit Canton",
      "category": "Instant Noodles",
      "stock": 8,
      "costPrice": 12.00,
      "sellingPrice": "₱18.00",
      "profitMargin": 50.0,
      "image": "https://images.unsplash.com/photo-1654663772654-5a972cbbbbd1",
      "semanticLabel":
          "Package of instant noodles with colorful wrapper showing noodles and vegetables",
      "barcode": "2345678901234",
      "description": "Instant pancit canton noodles with special sauce",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      "id": 3,
      "name": "Tide Detergent Powder 1kg",
      "category": "Household",
      "stock": 25,
      "costPrice": 85.00,
      "sellingPrice": "₱120.00",
      "profitMargin": 41.2,
      "image": "https://images.unsplash.com/photo-1517441275572-cba86fee9357",
      "semanticLabel":
          "White and orange detergent powder box with Tide branding on store shelf",
      "barcode": "3456789012345",
      "description":
          "High-quality laundry detergent powder for effective cleaning",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      "id": 4,
      "name": "Skyflakes Crackers",
      "category": "Snacks",
      "stock": 30,
      "costPrice": 8.00,
      "sellingPrice": "₱12.00",
      "profitMargin": 50.0,
      "image": "https://images.unsplash.com/photo-1636995973906-5af7d9832adb",
      "semanticLabel":
          "Stack of golden brown crackers on white plate with crumbs scattered around",
      "barcode": "4567890123456",
      "description": "Crispy and delicious crackers perfect for snacking",
      "lastUpdated": DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      "id": 5,
      "name": "Safeguard Soap Bar",
      "category": "Personal Care",
      "stock": 5,
      "costPrice": 25.00,
      "sellingPrice": "₱35.00",
      "profitMargin": 40.0,
      "image": "https://images.unsplash.com/photo-1653389521505-26c8c519c8f0",
      "semanticLabel":
          "White soap bar with blue Safeguard packaging on bathroom counter",
      "barcode": "5678901234567",
      "description": "Antibacterial soap bar for daily protection",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      "id": 6,
      "name": "Kopiko Coffee Candy",
      "category": "Candy",
      "stock": 50,
      "costPrice": 1.00,
      "sellingPrice": "₱2.00",
      "profitMargin": 100.0,
      "image": "https://images.unsplash.com/photo-1601577045284-97693a5b2de5",
      "semanticLabel":
          "Brown coffee candies scattered on wooden surface with coffee beans",
      "barcode": "6789012345678",
      "description": "Rich coffee-flavored hard candy",
      "lastUpdated": DateTime.now().subtract(const Duration(minutes: 15)),
    },
  ];

  // Demo categories with product counts
  final List<Map<String, dynamic>> _demoCategories = [
    {"name": "Beverages", "count": 1},
    {"name": "Instant Noodles", "count": 1},
    {"name": "Household", "count": 1},
    {"name": "Snacks", "count": 1},
    {"name": "Personal Care", "count": 1},
    {"name": "Candy", "count": 1},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered;

    if (_isDemoMode) {
      filtered = List.from(_demoProducts);
    } else {
      // Convert ProductModel to Map for compatibility with existing UI
      filtered = _products
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
    }

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

  // Method to manually switch to demo mode
  void _switchToDemoMode() {
    setState(() {
      _isDemoMode = true;
      _isLoading = false;
      _products = [];
      _categories = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Switched to demo mode'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Method to switch back to database mode
  void _switchToDatabaseMode() async {
    await _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isDemoMode
            ? 'Still in demo mode (no products in database)'
            : 'Switched to database mode'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productService.getAllProducts();

      // Check if we should use demo mode (no real products)
      if (products.isEmpty) {
        setState(() {
          _isDemoMode = true;
          _isLoading = false;
        });
      } else {
        // Get unique categories from real products
        final categories = products.map((p) => p.category).toSet().toList();

        setState(() {
          _products = products;
          _categories = categories;
          _isDemoMode = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // For demo purposes, fall back to demo mode on error
      setState(() {
        _isDemoMode = true;
        _isLoading = false;
      });
    }
  }

  // Method to refresh products after purchase (called from checkout)
  void _refreshProductsAfterPurchase() {
    if (!_isDemoMode) {
      _loadProducts();
    }
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
                          '${_filteredProducts.length} items in inventory${_isDemoMode ? " (Demo)" : ""}',
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
                        onPressed: _isDemoMode
                            ? _switchToDatabaseMode
                            : _switchToDemoMode,
                        icon: CustomIconWidget(
                          iconName: _isDemoMode ? 'database' : 'preview',
                          color: AppTheme.primaryLight,
                          size: 24,
                        ),
                        tooltip: _isDemoMode
                            ? 'Switch to Database Mode'
                            : 'Switch to Demo Mode',
                      ),
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
              categories: _isDemoMode
                  ? _demoCategories
                  : _categories
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
      bottomNavigationBar: _buildBottomNavigationBar(),

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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0, // Products tab is active
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryLight,
        unselectedItemColor: AppTheme.textSecondaryLight,
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.inventory_2_outlined,
              color: AppTheme.textSecondaryLight,
              size: 24,
            ),
            activeIcon: Icon(
              Icons.inventory_2,
              color: AppTheme.primaryLight,
              size: 24,
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.analytics_outlined,
              color: AppTheme.textSecondaryLight,
              size: 24,
            ),
            activeIcon: Icon(
              Icons.analytics,
              color: AppTheme.primaryLight,
              size: 24,
            ),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.warehouse_outlined,
              color: AppTheme.textSecondaryLight,
              size: 24,
            ),
            activeIcon: Icon(
              Icons.warehouse,
              color: AppTheme.primaryLight,
              size: 24,
            ),
            label: 'Stock',
          ),
        ],
      ),
    );
  }

  Future<void> _refreshProducts() async {
    if (_isDemoMode) {
      // Simulate refresh for demo mode
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isLoading = false;
      });
    } else {
      // Refresh real data
      await _loadProducts();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Products refreshed successfully${_isDemoMode ? " (Demo)" : ""}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showBarcodeScanner() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        height: 30.h,
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: AppTheme.primaryLight,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Barcode Scanner',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Scan product barcodes to quickly find or add items',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement barcode scanning
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barcode scanner feature coming soon'),
                    ),
                  );
                },
                child: const Text('Start Scanning'),
              ),
            ),
          ],
        ),
      ),
    );
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
    // Navigate to edit product screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${product["name"]}'),
      ),
    );
  }

  void _deleteProduct(Map<String, dynamic> product) {
    if (_isDemoMode) {
      // Can't delete demo products
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete demo products'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
    if (_isDemoMode) {
      // Can't update demo products
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update demo products'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
