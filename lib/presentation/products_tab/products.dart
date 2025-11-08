import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = false;

  // Mock data for products
  final List<Map<String, dynamic>> _allProducts = [
    {
      "id": 1,
      "name": "Coca-Cola 330ml",
      "category": "Beverages",
      "stock": 45,
      "costPrice": 15.00,
      "sellingPrice": "₱20.00",
      "profitMargin": 33.3,
      "image":
          "https://images.unsplash.com/photo-1675599591199-7bced32f7f97",
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
      "image":
          "https://images.unsplash.com/photo-1654663772654-5a972cbbbbd1",
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
      "image":
          "https://images.unsplash.com/photo-1517441275572-cba86fee9357",
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
      "image":
          "https://images.unsplash.com/photo-1636995973906-5af7d9832adb",
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
      "image":
          "https://images.unsplash.com/photo-1653389521505-26c8c519c8f0",
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
      "image":
          "https://images.unsplash.com/photo-1601577045284-97693a5b2de5",
      "semanticLabel":
          "Brown coffee candies scattered on wooden surface with coffee beans",
      "barcode": "6789012345678",
      "description": "Rich coffee-flavored hard candy",
      "lastUpdated": DateTime.now().subtract(const Duration(minutes: 15)),
    },
  ];

  // Mock categories with product counts
  final List<Map<String, dynamic>> _categories = [
    {"name": "Beverages", "count": 1},
    {"name": "Instant Noodles", "count": 1},
    {"name": "Household", "count": 1},
    {"name": "Snacks", "count": 1},
    {"name": "Personal Care", "count": 1},
    {"name": "Candy", "count": 1},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = _allProducts;

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

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                          '${_allProducts.length} items in inventory',
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
              categories: _categories,
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
            icon: CustomIconWidget(
              iconName: 'inventory_2_outlined',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'inventory_2',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'analytics_outlined',
              color: AppTheme.textSecondaryLight,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'analytics',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'warehouse_outlined',
              color: AppTheme.textSecondaryLight,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'warehouse',
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
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Products refreshed successfully'),
          duration: Duration(seconds: 2),
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
      builder: (context) => Container(
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
            ListTile(
              leading: CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: const Text('Low Stock Items'),
              subtitle: const Text('Products with 10 or fewer items'),
              onTap: () {
                Navigator.pop(context);
                // Filter for low stock items
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'trending_up',
                color: AppTheme.successLight,
                size: 24,
              ),
              title: const Text('High Profit Margin'),
              subtitle: const Text('Products with 30%+ profit margin'),
              onTap: () {
                Navigator.pop(context);
                // Filter for high profit items
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              title: const Text('Recently Updated'),
              subtitle: const Text('Products updated in last 24 hours'),
              onTap: () {
                Navigator.pop(context);
                // Filter for recently updated items
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
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
    );
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
    setState(() {
      _allProducts.removeWhere((p) => p["id"] == product["id"]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product["name"]} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _allProducts.add(product);
            });
          },
        ),
      ),
    );
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
              onSubmitted: (value) {
                final newStock = int.tryParse(value);
                if (newStock != null) {
                  setState(() {
                    product["stock"] = newStock;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stock updated for ${product["name"]}'),
                    ),
                  );
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
