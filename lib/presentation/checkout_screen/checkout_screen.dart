import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/transaction_service.dart';
import './widgets/cart_item_widget.dart';
import './widgets/product_search_widget.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  
  const CheckoutScreen({
    super.key,
    this.product,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();
  
  List<ProductModel> _allProducts = [];
  List<Map<String, dynamic>> _cartItems = []; // {productId, product, quantity}
  bool _isLoading = false;
  bool _isProcessing = false;
  String _searchQuery = '';
  
  // Single product checkout state
  int _singleProductQuantity = 1;

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
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<ProductModel> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return _allProducts.where((p) => p.stock > 0).toList();
    }
    return _allProducts
        .where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            p.stock > 0)
        .toList();
  }

  void _addToCart(ProductModel product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['productId'] == product.id,
    );

    if (existingIndex >= 0) {
      // Increase quantity if already in cart
      final currentQuantity = _cartItems[existingIndex]['quantity'] as int;
      if (currentQuantity < product.stock) {
        setState(() {
          _cartItems[existingIndex]['quantity'] = currentQuantity + 1;
        });
        HapticFeedback.lightImpact();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient stock. Available: ${product.stock}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Add new item to cart
      setState(() {
        _cartItems.add({
          'productId': product.id,
          'product': product,
          'quantity': 1,
        });
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _updateCartQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }

    final product = _cartItems[index]['product'] as ProductModel;
    if (newQuantity > product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient stock. Available: ${product.stock}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _cartItems[index]['quantity'] = newQuantity;
    });
    HapticFeedback.lightImpact();
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    HapticFeedback.mediumImpact();
  }

  double get _cartTotal {
    double total = 0;
    for (final item in _cartItems) {
      final product = item['product'] as ProductModel;
      final quantity = item['quantity'] as int;
      total += product.sellingPrice * quantity;
    }
    return total;
  }

  Future<void> _completePurchase() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm purchase
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text(
          'Total Amount: ₱${_cartTotal.toStringAsFixed(2)}\n\n'
          'Items: ${_cartItems.length}\n\n'
          'Proceed with purchase?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Prepare transaction items
      final transactionItems = _cartItems.map((item) {
        return {
          'productId': item['productId'] as int,
          'quantity': item['quantity'] as int,
        };
      }).toList();

      // Create transaction (this will decrease stock automatically)
      await _transactionService.createTransaction(transactionItems);

      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Purchase completed! Total: ₱${_cartTotal.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successLight,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear cart
        setState(() {
          _cartItems.clear();
        });

        // Reload products to update stock
        await _loadProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing purchase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Single product checkout methods
  void _incrementSingleProductQuantity() {
    if (widget.product != null) {
      final stock = (widget.product!["stock"] as int?) ?? 0;
      if (_singleProductQuantity < stock) {
        setState(() {
          _singleProductQuantity++;
        });
        HapticFeedback.lightImpact();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient stock. Available: $stock'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _decrementSingleProductQuantity() {
    if (_singleProductQuantity > 1) {
      setState(() {
        _singleProductQuantity--;
      });
      HapticFeedback.lightImpact();
    }
  }

  double get _singleProductTotal {
    if (widget.product == null) return 0.0;
    final price = double.tryParse(
      (widget.product!["sellingPrice"] as String?)?.replaceAll('₱', '') ?? '0'
    ) ?? 0.0;
    return price * _singleProductQuantity;
  }

  Future<void> _completeSingleProductPurchase() async {
    if (widget.product == null) return;

    final stock = (widget.product!["stock"] as int?) ?? 0;
    if (_singleProductQuantity > stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient stock. Available: $stock'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm purchase
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text(
          'Product: ${widget.product!["name"]}\n'
          'Quantity: $_singleProductQuantity\n'
          'Total Amount: ₱${_singleProductTotal.toStringAsFixed(2)}\n\n'
          'Proceed with purchase?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Buy'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create transaction for single product
      final transactionItems = [
        {
          'productId': widget.product!["id"] as int,
          'quantity': _singleProductQuantity,
        }
      ];

      await _transactionService.createTransaction(transactionItems);

      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Purchase completed! Total: ₱${_singleProductTotal.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successLight,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing purchase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildSingleProductCheckout() {
    final product = widget.product!;
    final productName = (product["name"] as String?) ?? "Unknown Product";
    final productImage = (product["image"] as String?) ?? "";
    final sellingPrice = (product["sellingPrice"] as String?) ?? "₱0.00";
    final price = double.tryParse(sellingPrice.replaceAll('₱', '')) ?? 0.0;
    final stock = (product["stock"] as int?) ?? 0;
    final category = (product["category"] as String?) ?? "";
    final description = (product["description"] as String?) ?? "";

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Information Card
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Details',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.lightTheme.colorScheme.surface,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(
                            imageUrl: productImage,
                            width: 20.w,
                            height: 20.w,
                            fit: BoxFit.cover,
                            semanticLabel: productName,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      // Product Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              category,
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                            if (description.isNotEmpty) ...[
                              SizedBox(height: 1.h),
                              Text(
                                description,
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryLight,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'inventory_2',
                                  color: stock <= 10
                                      ? AppTheme.errorLight
                                      : AppTheme.textSecondaryLight,
                                  size: 4.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Stock: $stock',
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: stock <= 10
                                        ? AppTheme.errorLight
                                        : AppTheme.textSecondaryLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Quantity Picker Card
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantity',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Decrement Button
                      GestureDetector(
                        onTap: _singleProductQuantity > 1
                            ? _decrementSingleProductQuantity
                            : null,
                        child: Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: _singleProductQuantity > 1
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'remove',
                              color: _singleProductQuantity > 1
                                  ? Colors.white
                                  : AppTheme.lightTheme.colorScheme.outline,
                              size: 6.w,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Quantity Display
                      Container(
                        width: 30.w,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _singleProductQuantity.toString(),
                              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'pieces',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Increment Button
                      GestureDetector(
                        onTap: _singleProductQuantity < stock
                            ? _incrementSingleProductQuantity
                            : null,
                        child: Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            color: _singleProductQuantity < stock
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'add',
                              color: _singleProductQuantity < stock
                                  ? Colors.white
                                  : AppTheme.lightTheme.colorScheme.outline,
                              size: 6.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Price and Total Card
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Summary',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Unit Price:',
                        style: AppTheme.lightTheme.textTheme.bodyLarge,
                      ),
                      Text(
                        sellingPrice,
                        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity:',
                        style: AppTheme.lightTheme.textTheme.bodyLarge,
                      ),
                      Text(
                        '$_singleProductQuantity',
                        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Divider(
                    color: AppTheme.dividerLight,
                    thickness: 1,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₱${_singleProductTotal.toStringAsFixed(2)}',
                        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 6.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing || stock == 0
                        ? null
                        : _completeSingleProductPurchase,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'shopping_cart',
                                color: Colors.white,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Buy',
                                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show single product checkout if product is provided
    if (widget.product != null) {
      return _buildSingleProductCheckout();
    }

    // Otherwise show the regular cart checkout
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          ProductSearchWidget(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),

          // Products list and cart
          Expanded(
            child: Row(
              children: [
                // Products list
                Expanded(
                  flex: 2,
                  child: Container(
                    color: AppTheme.lightTheme.scaffoldBackgroundColor,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'inventory',
                                      color: AppTheme.textSecondaryLight,
                                      size: 15.w,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      _searchQuery.isEmpty
                                          ? 'No products available'
                                          : 'No products found',
                                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(2.w),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  final inCart = _cartItems.any(
                                    (item) => item['productId'] == product.id,
                                  );
                                  final cartItem = inCart
                                      ? _cartItems.firstWhere(
                                          (item) => item['productId'] == product.id,
                                        )
                                      : null;
                                  final cartQuantity = cartItem?['quantity'] as int? ?? 0;

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 2.h),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
                                        child: CustomIconWidget(
                                          iconName: 'inventory',
                                          color: AppTheme.primaryLight,
                                          size: 5.w,
                                        ),
                                      ),
                                      title: Text(
                                        product.name,
                                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '₱${product.sellingPrice.toStringAsFixed(2)}',
                                            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                                              color: AppTheme.primaryLight,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Text(
                                            'Stock: ${product.stock}',
                                            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                              color: product.stock <= 10
                                                  ? AppTheme.errorLight
                                                  : AppTheme.textSecondaryLight,
                                            ),
                                          ),
                                          if (inCart) ...[
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              'In cart: $cartQuantity',
                                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                                color: AppTheme.successLight,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      trailing: IconButton(
                                        onPressed: product.stock > 0
                                            ? () => _addToCart(product)
                                            : null,
                                        icon: CustomIconWidget(
                                          iconName: 'add_shopping_cart',
                                          color: product.stock > 0
                                              ? AppTheme.primaryLight
                                              : AppTheme.textDisabledLight,
                                          size: 6.w,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),

                // Cart section
                Container(
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    border: Border(
                      left: BorderSide(
                        color: AppTheme.dividerLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Cart header
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'shopping_cart',
                              color: Colors.white,
                              size: 6.w,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                'Cart (${_cartItems.length})',
                                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Cart items
                      Expanded(
                        child: _cartItems.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'shopping_cart',
                                      color: AppTheme.textSecondaryLight,
                                      size: 15.w,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Cart is empty',
                                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(2.w),
                                itemCount: _cartItems.length,
                                itemBuilder: (context, index) {
                                  return CartItemWidget(
                                    product: _cartItems[index]['product'] as ProductModel,
                                    quantity: _cartItems[index]['quantity'] as int,
                                    onQuantityChanged: (newQuantity) {
                                      _updateCartQuantity(index, newQuantity);
                                    },
                                    onRemove: () {
                                      _removeFromCart(index);
                                    },
                                  );
                                },
                              ),
                      ),

                      // Cart footer with total and checkout button
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          border: Border(
                            top: BorderSide(
                              color: AppTheme.dividerLight,
                              width: 1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total:',
                                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₱${_cartTotal.toStringAsFixed(2)}',
                                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                    color: AppTheme.primaryLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isProcessing || _cartItems.isEmpty ? null : _completePurchase,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 2.h),
                                  backgroundColor: AppTheme.primaryLight,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isProcessing
                                    ? SizedBox(
                                        width: 5.w,
                                        height: 5.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomIconWidget(
                                            iconName: 'check_circle',
                                            color: Colors.white,
                                            size: 5.w,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            'Complete Purchase',
                                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

