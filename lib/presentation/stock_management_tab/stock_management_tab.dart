import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../data/models/product_model.dart';
import '../../services/product_service.dart';
import './widgets/stock_adjustment_modal.dart';
import './widgets/stock_filter_chips.dart';
import './widgets/stock_item_card.dart';
import './widgets/stock_search_bar.dart';

class StockManagementTab extends StatefulWidget {
  const StockManagementTab({super.key});

  @override
  State<StockManagementTab> createState() => _StockManagementTabState();
}

class _StockManagementTabState extends State<StockManagementTab>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'name';
  bool _isMultiSelectMode = false;
  bool _isLoading = true;
  bool _isDemoMode = false;
  final Set<int> _selectedProducts = {};
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];

  // Demo data for stock management
  final List<Map<String, dynamic>> _demoStockData = [
    {
      "id": 1,
      "name": "Coca-Cola 1.5L",
      "category": "Beverages",
      "currentStock": 0,
      "reorderLevel": 10,
      "price": 65.00,
      "barcode": "4902430123456",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 2)),
      "supplier": "Coca-Cola Philippines",
    },
    {
      "id": 2,
      "name": "Lucky Me Pancit Canton",
      "category": "Instant Noodles",
      "currentStock": 5,
      "reorderLevel": 20,
      "price": 15.50,
      "barcode": "4902430789012",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 1)),
      "supplier": "Monde Nissin",
    },
    {
      "id": 3,
      "name": "Tide Powder 1kg",
      "category": "Household",
      "currentStock": 25,
      "reorderLevel": 15,
      "price": 185.00,
      "barcode": "4902430345678",
      "lastUpdated": DateTime.now().subtract(const Duration(minutes: 30)),
      "supplier": "Procter & Gamble",
    },
    {
      "id": 4,
      "name": "San Miguel Beer 330ml",
      "category": "Beverages",
      "currentStock": 8,
      "reorderLevel": 12,
      "price": 45.00,
      "barcode": "4902430901234",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 3)),
      "supplier": "San Miguel Corporation",
    },
    {
      "id": 5,
      "name": "Maggi Magic Sarap 50g",
      "category": "Seasonings",
      "currentStock": 35,
      "reorderLevel": 20,
      "price": 28.75,
      "barcode": "4902430567890",
      "lastUpdated": DateTime.now().subtract(const Duration(minutes: 45)),
      "supplier": "Nestle Philippines",
    },
    {
      "id": 6,
      "name": "Palmolive Shampoo 400ml",
      "category": "Personal Care",
      "currentStock": 3,
      "reorderLevel": 10,
      "price": 125.00,
      "barcode": "4902430234567",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 4)),
      "supplier": "Colgate-Palmolive",
    },
    {
      "id": 7,
      "name": "Skyflakes Crackers",
      "category": "Snacks",
      "currentStock": 18,
      "reorderLevel": 15,
      "price": 32.50,
      "barcode": "4902430678901",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 2)),
      "supplier": "Ricoa",
    },
    {
      "id": 8,
      "name": "Downy Fabric Conditioner 1L",
      "category": "Household",
      "currentStock": 12,
      "reorderLevel": 8,
      "price": 155.00,
      "barcode": "4902430890123",
      "lastUpdated": DateTime.now().subtract(const Duration(minutes: 15)),
      "supplier": "Procter & Gamble",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
    _loadProducts();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productService.getAllProducts();
      setState(() {
        _products = products;
        _isDemoMode = false;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to demo mode on error
      setState(() {
        _isDemoMode = true;
        _isLoading = false;
      });
      _loadDemoProducts();
    }
  }

  void _loadDemoProducts() {
    // Convert demo data to ProductModel format for consistency
    _products = _demoStockData
        .map((data) => ProductModel(
              id: data['id'] as int,
              name: data['name'] as String,
              category: data['category'] as String,
              barcode: data['barcode'] as String,
              costPrice: 10.0, // Mock cost price
              sellingPrice: data['price'] as double,
              stock: data['currentStock'] as int,
              createdAt: DateTime.now().subtract(const Duration(days: 30)),
              updatedAt: data['lastUpdated'] as DateTime,
            ))
        .toList();
  }

  void _switchToDemoMode() {
    setState(() {
      _isDemoMode = true;
    });
    _loadDemoProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Switched to demo mode'),
        duration: Duration(seconds: 2),
      ),
    );
  }

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
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();
    final filterCounts = _getFilterCounts();

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Stock Management',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: 2,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/products-tab');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/analytics-tab');
                break;
              case 2:
                // Already on Stock Management tab
                break;
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Management${_isDemoMode ? " (Demo)" : ""}',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            Text(
              '${filteredProducts.length} products',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              onPressed: _selectAllProducts,
              icon: CustomIconWidget(
                iconName: 'select_all',
                color: AppTheme.textPrimaryLight,
                size: 24,
              ),
              tooltip: 'Select All',
            ),
            IconButton(
              onPressed: _exitMultiSelectMode,
              icon: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.textPrimaryLight,
                size: 24,
              ),
              tooltip: 'Exit Selection',
            ),
          ] else ...[
            IconButton(
              onPressed:
                  _isDemoMode ? _switchToDatabaseMode : _switchToDemoMode,
              icon: CustomIconWidget(
                iconName: _isDemoMode ? 'database' : 'preview',
                color: AppTheme.textPrimaryLight,
                size: 24,
              ),
              tooltip: _isDemoMode
                  ? 'Switch to Database Mode'
                  : 'Switch to Demo Mode',
            ),
            IconButton(
              onPressed: () => _showNotificationSettings(context),
              icon: Stack(
                children: [
                  CustomIconWidget(
                    iconName: 'notifications_outlined',
                    color: AppTheme.textPrimaryLight,
                    size: 24,
                  ),
                  if (_getLowStockCount() > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          _getLowStockCount().toString(),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Stock Alerts',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search and sort bar
          StockSearchBar(
            searchQuery: _searchQuery,
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onScanBarcode: _scanBarcode,
            sortBy: _sortBy,
            onSortChanged: (sortBy) {
              setState(() {
                _sortBy = sortBy;
              });
            },
          ),

          // Filter chips
          StockFilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            filterCounts: filterCounts,
          ),

          // Multi-select toolbar
          if (_isMultiSelectMode)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(color: AppTheme.dividerLight),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_selectedProducts.length} selected',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed:
                        _selectedProducts.isNotEmpty ? _bulkStockUpdate : null,
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.primaryLight,
                      size: 16,
                    ),
                    label: Text(
                      'Update Stock',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Product list
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshStockData,
                    color: AppTheme.primaryLight,
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final isSelected =
                            _selectedProducts.contains(product.id!);

                        return StockItemCard(
                          product: product,
                          isSelected: isSelected,
                          onTap: () => _handleProductTap(product.id!),
                          onStockAdjustment: () =>
                              _showStockAdjustmentModal(product),
                          onReorder: () => _handleReorder(product),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/add-product-screen'),
          backgroundColor: AppTheme.primaryLight,
          foregroundColor: Colors.white,
          icon: CustomIconWidget(
            iconName: 'add',
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            'Add Product',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2, // Stock Management tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/products-tab');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/analytics-tab');
              break;
            case 2:
              // Already on Stock Management tab
              break;
          }
        },
      ),
    );
  }

  List<ProductModel> _getFilteredProducts() {
    List<ProductModel> filtered = List.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = product.name.toLowerCase();
        final barcode = (product.barcode ?? '').toLowerCase();
        final category = product.category.toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            barcode.contains(query) ||
            category.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((product) {
        final status = _getStockStatus(
            product.stock, 10); // Using default reorder level of 10
        return status == _selectedFilter;
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'stock_low':
          return a.stock.compareTo(b.stock);
        case 'stock_high':
          return b.stock.compareTo(a.stock);
        case 'status':
          final statusA = _getStockStatus(a.stock, 10);
          final statusB = _getStockStatus(b.stock, 10);
          final statusOrder = {
            'Out of Stock': 0,
            'Low Stock': 1,
            'In Stock': 2
          };
          return (statusOrder[statusA] ?? 3)
              .compareTo(statusOrder[statusB] ?? 3);
        case 'category':
          return a.category.compareTo(b.category);
        default:
          return 0;
      }
    });

    return filtered;
  }

  Map<String, int> _getFilterCounts() {
    final counts = <String, int>{
      'All': _products.length,
      'In Stock': 0,
      'Low Stock': 0,
      'Out of Stock': 0,
    };

    for (final product in _products) {
      final status = _getStockStatus(
          product.stock, 10); // Using default reorder level of 10
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  String _getStockStatus(int currentStock, int reorderLevel) {
    if (currentStock == 0) return 'Out of Stock';
    if (currentStock <= reorderLevel) return 'Low Stock';
    return 'In Stock';
  }

  int _getLowStockCount() {
    return _products.where((product) {
      return product.stock <= 10; // Using default reorder level of 10
    }).length;
  }

  void _handleProductTap(int productId) {
    if (_isMultiSelectMode) {
      setState(() {
        if (_selectedProducts.contains(productId)) {
          _selectedProducts.remove(productId);
        } else {
          _selectedProducts.add(productId);
        }

        if (_selectedProducts.isEmpty) {
          _isMultiSelectMode = false;
        }
      });
      HapticFeedback.selectionClick();
    } else {
      // Long press to enter multi-select mode
      setState(() {
        _isMultiSelectMode = true;
        _selectedProducts.add(productId);
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _selectAllProducts() {
    setState(() {
      _selectedProducts.clear();
      _selectedProducts.addAll(_getFilteredProducts().map((p) => p.id!));
    });
    HapticFeedback.selectionClick();
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedProducts.clear();
    });
  }

  void _showStockAdjustmentModal(ProductModel product) {
    if (_isDemoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock adjustments are disabled in demo mode'),
          backgroundColor: AppTheme.warningLight,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StockAdjustmentModal(
          product: product,
          onStockUpdated: (newStock, reason) async {
            try {
              await _productService.adjustStock(product.id!, newStock, reason);
              await _loadProducts(); // Refresh the list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Stock updated successfully'),
                  backgroundColor: AppTheme.successLight,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to update stock: $e'),
                  backgroundColor: AppTheme.errorLight,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _handleReorder(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reorder Product',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a reorder request for:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              product.name,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Current Stock: ${product.stock} units',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            Text(
              'Reorder Level: 10 units', // Using default reorder level
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reorder request created for ${product.name}'),
                  backgroundColor: AppTheme.successLight,
                ),
              );
              // TODO: Implement actual reorder functionality with backend
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Create Request',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _bulkStockUpdate() async {
    if (_selectedProducts.isEmpty) return;

    if (_isDemoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bulk stock updates are disabled in demo mode'),
          backgroundColor: AppTheme.warningLight,
        ),
      );
      _exitMultiSelectMode();
      return;
    }

    // Get selected products
    final selectedProducts =
        _products.where((p) => _selectedProducts.contains(p.id)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Bulk Stock Update',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update stock levels for ${selectedProducts.length} selected products?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            ...selectedProducts.take(3).map((product) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Text(
                    '• ${product.name} (${product.stock} units)',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                )),
            if (selectedProducts.length > 3)
              Text(
                '... and ${selectedProducts.length - 3} more',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // TODO: Implement bulk stock adjustment with proper UI
                // For now, just show a message
                _exitMultiSelectMode();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bulk update feature coming soon'),
                    backgroundColor: AppTheme.primaryLight,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update stock: $e'),
                    backgroundColor: AppTheme.errorLight,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Update',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scanBarcode() {
    // Mock barcode scanning functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Barcode scanner feature coming soon'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  Future<void> _refreshStockData() async {
    try {
      await _loadProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock data refreshed'),
          backgroundColor: AppTheme.successLight,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh data: $e'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  void _showNotificationSettings(BuildContext context) {
    final lowStockProducts =
        _products.where((product) => product.stock <= 10).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Stock Alerts',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have ${lowStockProducts.length} products that need attention:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            ...lowStockProducts.take(3).map((product) {
              final status = _getStockStatus(product.stock, 10);
              return Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: status == 'Out of Stock'
                            ? AppTheme.errorLight
                            : AppTheme.warningLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        '${product.name} (${product.stock} left)',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedFilter = 'Low Stock';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'View All',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'inventory_2',
              color: AppTheme.textDisabledLight,
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No products found'
                  : 'No products in stock',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Start by adding products to your inventory',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textDisabledLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/add-product-screen'),
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Add Product',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
