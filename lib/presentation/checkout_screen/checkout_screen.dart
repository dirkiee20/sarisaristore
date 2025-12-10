import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/product_model.dart';
import '../../services/transaction_service.dart';
import './widgets/cart_item_widget.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  final bool cartOnly;
  final List<Map<String, dynamic>>? cartItems;

  const CheckoutScreen({
    super.key,
    this.product,
    this.cartOnly = false,
    this.cartItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TransactionService _transactionService = TransactionService();

  List<Map<String, dynamic>> _cartItems = []; // {productId, product, quantity}
  bool _isProcessing = false;

  // Single product checkout state
  int _singleProductQuantity = 1;

  // Payment state
  String? _selectedPaymentMethod;
  double? _paymentAmount;

  // Customer state
  String? _customerName;
  String? _customerContact;
  bool _showCustomerDetails = false;

  @override
  void initState() {
    super.initState();
    // Initialize cart items from arguments if provided
    if (widget.cartItems != null) {
      _cartItems = List.from(widget.cartItems!);
    }
  }

  void _updateCartQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeFromCart(index);
      return;
    }

    final product = _cartItems[index]['productModel'] as ProductModel;
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
      final product = item['productModel'] as ProductModel;
      final quantity = item['quantity'] as int;
      total += product.sellingPrice * quantity;
    }
    return total;
  }

  Future<Map<String, dynamic>?> _showPaymentDialog(double totalAmount) async {
    _selectedPaymentMethod = null;
    _paymentAmount = null;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Payment Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount: ₱${totalAmount.toStringAsFixed(2)}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryLight,
                  ),
                ),
                SizedBox(height: 3.h),

                // Payment Method Selection
                Text(
                  'Payment Method',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Cash'),
                        value: 'cash',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('GCash'),
                        value: 'gcash',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        dense: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Credit'),
                        value: 'credit',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value;
                          });
                        },
                        dense: true,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Payment Amount Input
                Text(
                  'Payment Amount',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter payment amount',
                    prefixText: '₱',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    _paymentAmount = double.tryParse(value) ?? 0.0;
                  },
                ),

                SizedBox(height: 2.h),

                // Change Display
                if (_paymentAmount != null &&
                    _paymentAmount! >= totalAmount) ...[
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.successLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.successLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change:',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₱${(_paymentAmount! - totalAmount).toStringAsFixed(2)}',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.successLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_paymentAmount != null &&
                    _paymentAmount! < totalAmount) ...[
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.errorLight.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Insufficient payment amount',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.errorLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: (_selectedPaymentMethod != null &&
                      _paymentAmount != null &&
                      _paymentAmount! >= totalAmount)
                  ? () => Navigator.pop(context, {
                        'paymentMethod': _selectedPaymentMethod,
                        'paymentAmount': _paymentAmount,
                        'change': _paymentAmount! - totalAmount,
                      })
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
              ),
              child: const Text('Complete Payment'),
            ),
          ],
        ),
      ),
    );
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

    if (_selectedPaymentMethod == null || _paymentAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select payment method and enter payment amount'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_paymentAmount! < _cartTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment amount is insufficient'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Prepare transaction items
      final transactionItems = _cartItems.map((item) {
        final productModel = item['productModel'] as ProductModel;
        return {
          'productId': productModel.id as int,
          'quantity': item['quantity'] as int,
        };
      }).toList();

      // Create transaction with payment data (this will decrease stock automatically)
      await _transactionService.createTransaction(
        transactionItems,
        paymentMethod: _selectedPaymentMethod!,
        paymentAmount: _paymentAmount!,
        customerName: _customerName,
        customerContact: _customerContact,
      );

      HapticFeedback.mediumImpact();

      final change = _paymentAmount! - _cartTotal;

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
                    'Purchase completed! Total: ₱${_cartTotal.toStringAsFixed(2)}, Change: ₱${change.toStringAsFixed(2)}',
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

        // Clear cart and return success
        setState(() {
          _cartItems.clear();
          _selectedPaymentMethod = null;
          _paymentAmount = null;
        });

        // Return true to indicate successful purchase
        Navigator.pop(context, true);
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
            (widget.product!["sellingPrice"] as String?)?.replaceAll('₱', '') ??
                '0') ??
        0.0;
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

    if (_selectedPaymentMethod == null || _paymentAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please select payment method and enter payment amount'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_paymentAmount! < _singleProductTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment amount is insufficient'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

      await _transactionService.createTransaction(
        transactionItems,
        paymentMethod: _selectedPaymentMethod!,
        paymentAmount: _paymentAmount!,
        customerName: _customerName,
        customerContact: _customerContact,
      );

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
                    'Purchase completed! Total: ₱${_singleProductTotal.toStringAsFixed(2)}, Change: ₱${(_paymentAmount! - _singleProductTotal).toStringAsFixed(2)}',
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

  Widget _buildCartOnlyCheckout() {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Cart Checkout'),
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
      body: Column(
        children: [
          // Cart section (full width)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
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
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
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
                                  'Your cart is empty',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Add items from the Products tab',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
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
                                product: _cartItems[index]['productModel']
                                    as ProductModel,
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

                  // Customer Details Section (Optional)
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.dividerLight,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Details Header with Toggle
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showCustomerDetails = !_showCustomerDetails;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'person',
                                      color: AppTheme.primaryLight,
                                      size: 5.w,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'Customer Details (Optional)',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                CustomIconWidget(
                                  iconName: _showCustomerDetails
                                      ? 'expand_less'
                                      : 'expand_more',
                                  color: AppTheme.textSecondaryLight,
                                  size: 5.w,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Customer Input Fields (Conditional)
                        if (_showCustomerDetails) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Customer Name Input
                                Text(
                                  'Customer Name',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter customer name',
                                    prefixIcon: CustomIconWidget(
                                      iconName: 'person',
                                      color: AppTheme.textSecondaryLight,
                                      size: 5.w,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _customerName = value.trim().isEmpty
                                          ? null
                                          : value.trim();
                                    });
                                  },
                                ),

                                SizedBox(height: 2.h),

                                // Customer Contact Input
                                Text(
                                  'Contact Number',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                TextFormField(
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Enter contact number',
                                    prefixIcon: CustomIconWidget(
                                      iconName: 'phone',
                                      color: AppTheme.textSecondaryLight,
                                      size: 5.w,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _customerContact = value.trim().isEmpty
                                          ? null
                                          : value.trim();
                                    });
                                  },
                                ),
                                SizedBox(height: 3.w),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Payment Details Section
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Details',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Payment Method Selection
                        Text(
                          'Payment Method',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Cash'),
                                value: 'cash',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethod = value;
                                  });
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('GCash'),
                                value: 'gcash',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethod = value;
                                  });
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Credit'),
                                value: 'credit',
                                groupValue: _selectedPaymentMethod,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethod = value;
                                  });
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 2.h),

                        // Payment Amount Input
                        Text(
                          'Payment Amount',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        TextFormField(
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Enter payment amount',
                            prefixText: '₱',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _paymentAmount = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),

                        // Change Display
                        if (_paymentAmount != null &&
                            _paymentAmount! >= _cartTotal) ...[
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.successLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.successLight
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Change:',
                                  style: AppTheme.lightTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₱${(_paymentAmount! - _cartTotal).toStringAsFixed(2)}',
                                  style: AppTheme.lightTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.successLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (_paymentAmount != null &&
                            _paymentAmount! < _cartTotal) ...[
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.errorLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    AppTheme.errorLight.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'Insufficient payment amount',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.errorLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
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
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '₱${_cartTotal.toStringAsFixed(2)}',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
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
                            onPressed: _isProcessing ||
                                    _cartItems.isEmpty ||
                                    _selectedPaymentMethod == null ||
                                    _paymentAmount == null ||
                                    _paymentAmount! < _cartTotal
                                ? null
                                : _completePurchase,
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
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
                                        style: AppTheme
                                            .lightTheme.textTheme.titleMedium
                                            ?.copyWith(
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
          ),
        ],
      ),
    );
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
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              category,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                            if (description.isNotEmpty) ...[
                              SizedBox(height: 1.h),
                              Text(
                                description,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
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
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
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
                                : AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.3),
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
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _singleProductQuantity.toString(),
                              style: AppTheme
                                  .lightTheme.textTheme.headlineMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'pieces',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
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
                                : AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.3),
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
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
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
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
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
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₱${_singleProductTotal.toStringAsFixed(2)}',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Customer Details Section (Optional)
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
                  // Customer Details Header with Toggle
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showCustomerDetails = !_showCustomerDetails;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'person',
                              color: AppTheme.primaryLight,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Customer Details (Optional)',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        CustomIconWidget(
                          iconName: _showCustomerDetails
                              ? 'expand_less'
                              : 'expand_more',
                          color: AppTheme.textSecondaryLight,
                          size: 5.w,
                        ),
                      ],
                    ),
                  ),

                  // Customer Input Fields (Conditional)
                  if (_showCustomerDetails) ...[
                    SizedBox(height: 3.h),
                    // Customer Name Input
                    Text(
                      'Customer Name',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter customer name',
                        prefixIcon: CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.textSecondaryLight,
                          size: 5.w,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _customerName =
                              value.trim().isEmpty ? null : value.trim();
                        });
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Customer Contact Input
                    Text(
                      'Contact Number',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter contact number',
                        prefixIcon: CustomIconWidget(
                          iconName: 'phone',
                          color: AppTheme.textSecondaryLight,
                          size: 5.w,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _customerContact =
                              value.trim().isEmpty ? null : value.trim();
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Payment Details Card
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
                    'Payment Details',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Payment Method Selection
                  Text(
                    'Payment Method',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Cash'),
                          value: 'cash',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('GCash'),
                          value: 'gcash',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Credit'),
                          value: 'credit',
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Payment Amount Input
                  Text(
                    'Payment Amount',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextFormField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter payment amount',
                      prefixText: '₱',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _paymentAmount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),

                  // Change Display
                  if (_paymentAmount != null &&
                      _paymentAmount! >= _singleProductTotal) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.successLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.successLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Change:',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₱${(_paymentAmount! - _singleProductTotal).toStringAsFixed(2)}',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.successLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_paymentAmount != null &&
                      _paymentAmount! < _singleProductTotal) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.errorLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.errorLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Insufficient payment amount',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.errorLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isProcessing ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isProcessing ||
                            stock == 0 ||
                            _selectedPaymentMethod == null ||
                            _paymentAmount == null ||
                            _paymentAmount! < _singleProductTotal
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
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
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
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
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

    // Show cart-only checkout if cartOnly is true
    if (widget.cartOnly) {
      return _buildCartOnlyCheckout();
    }

    // Default to cart-only if no specific mode
    return _buildCartOnlyCheckout();
  }
}
