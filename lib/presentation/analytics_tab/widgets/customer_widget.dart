import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../services/transaction_service.dart';
import '../../../services/product_service.dart';

class CustomerWidget extends StatefulWidget {
  const CustomerWidget({super.key});

  @override
  State<CustomerWidget> createState() => _CustomerWidgetState();
}

class _CustomerWidgetState extends State<CustomerWidget> {
  List<Map<String, dynamic>> _recentCustomers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get recent transactions with customer data
      final transactionService = TransactionService();
      final transactions = await transactionService.getAllTransactions();

      // Extract unique customers from transactions
      final customerMap = <String, Map<String, dynamic>>{};

      for (final transaction in transactions) {
        if (transaction.customerName != null &&
            transaction.customerName!.isNotEmpty) {
          final customerKey =
              '${transaction.customerName}_${transaction.customerContact ?? ''}';

          if (!customerMap.containsKey(customerKey)) {
            customerMap[customerKey] = {
              'name': transaction.customerName,
              'contact': transaction.customerContact,
              'totalTransactions': 0,
              'totalSpent': 0.0,
              'lastTransaction': transaction.transactionDate,
            };
          }

          customerMap[customerKey]!['totalTransactions'] =
              (customerMap[customerKey]!['totalTransactions'] as int) + 1;
          customerMap[customerKey]!['totalSpent'] =
              (customerMap[customerKey]!['totalSpent'] as double) +
                  transaction.totalAmount;

          // Update last transaction date if more recent
          if (transaction.transactionDate.isAfter(
              customerMap[customerKey]!['lastTransaction'] as DateTime)) {
            customerMap[customerKey]!['lastTransaction'] =
                transaction.transactionDate;
          }
        }
      }

      // Convert to list and sort by last transaction date
      final customers = customerMap.values.toList();
      customers.sort((a, b) => (b['lastTransaction'] as DateTime)
          .compareTo(a['lastTransaction'] as DateTime));

      // Take top 5 recent customers
      setState(() {
        _recentCustomers = customers.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load customer data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'people',
                  color: Colors.white,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Recent Customers',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_recentCustomers.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Customer List
          if (_recentCustomers.isEmpty) ...[
            Container(
              padding: EdgeInsets.all(6.w),
              child: Center(
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'person_off',
                      color: AppTheme.textSecondaryLight,
                      size: 10.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No customer data yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Customer information will appear here when transactions include customer details',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _recentCustomers.length,
              itemBuilder: (context, index) {
                final customer = _recentCustomers[index];
                return _buildCustomerItem(
                    customer, index == _recentCustomers.length - 1);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerItem(Map<String, dynamic> customer, bool isLast) {
    final theme = Theme.of(context);
    final name = customer['name'] as String;
    final contact = customer['contact'] as String?;
    final totalTransactions = customer['totalTransactions'] as int;
    final totalSpent = customer['totalSpent'] as double;
    final lastTransaction = customer['lastTransaction'] as DateTime;

    return InkWell(
      onTap: () => _showCustomerDetails(customer),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(
                    color: AppTheme.dividerLight,
                    width: 1,
                  ),
          ),
        ),
        child: Row(
          children: [
            // Customer Avatar
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'person',
                  color: AppTheme.primaryLight,
                  size: 6.w,
                ),
              ),
            ),
            SizedBox(width: 3.w),

            // Customer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Contact
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (contact != null && contact.isNotEmpty) ...[
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName: 'phone',
                          color: AppTheme.textSecondaryLight,
                          size: 4.w,
                        ),
                      ],
                    ],
                  ),

                  if (contact != null && contact.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      contact,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],

                  SizedBox(height: 0.5.h),

                  // Transaction Summary
                  Row(
                    children: [
                      Text(
                        '$totalTransactions transaction${totalTransactions != 1 ? 's' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 1.w,
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        '₱${totalSpent.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Last Transaction
                  SizedBox(height: 0.5.h),
                  Text(
                    'Last: ${_formatDate(lastTransaction)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow indicator
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.textSecondaryLight,
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Future<void> _showCustomerDetails(Map<String, dynamic> customer) async {
    final name = customer['name'] as String;
    final contact = customer['contact'] as String?;

    // Get customer's purchase history
    final transactionService = TransactionService();
    final allTransactions = await transactionService.getAllTransactions();

    // Filter transactions for this customer
    final customerTransactions = allTransactions.where((transaction) {
      return transaction.customerName == name &&
          (contact == null || transaction.customerContact == contact);
    }).toList();

    // Get all products purchased by this customer
    final purchasedProducts = <String, Map<String, dynamic>>{};
    for (final transaction in customerTransactions) {
      final items =
          await transactionService.getTransactionItems(transaction.id!);
      for (final item in items) {
        final productKey = item.productId.toString();
        if (!purchasedProducts.containsKey(productKey)) {
          purchasedProducts[productKey] = {
            'productId': item.productId,
            'productName': item.productName,
            'totalQuantity': 0,
            'totalSpent': 0.0,
            'lastPurchased': transaction.transactionDate,
          };
        }
        purchasedProducts[productKey]!['totalQuantity'] =
            (purchasedProducts[productKey]!['totalQuantity'] as int) +
                item.quantity;
        purchasedProducts[productKey]!['totalSpent'] =
            (purchasedProducts[productKey]!['totalSpent'] as double) +
                item.subtotal;

        // Update last purchased date if more recent
        if (transaction.transactionDate.isAfter(
            purchasedProducts[productKey]!['lastPurchased'] as DateTime)) {
          purchasedProducts[productKey]!['lastPurchased'] =
              transaction.transactionDate;
        }
      }
    }

    final productsList = purchasedProducts.values.toList();
    productsList.sort((a, b) => (b['lastPurchased'] as DateTime)
        .compareTo(a['lastPurchased'] as DateTime));

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(maxHeight: 80.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'person',
                      color: Colors.white,
                      size: 6.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (contact != null && contact.isNotEmpty) ...[
                            Text(
                              contact,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.white,
                        size: 5.w,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Summary
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.dividerLight,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${customerTransactions.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryLight,
                                      ),
                                ),
                                Text(
                                  'Transactions',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '₱${(customer['totalSpent'] as double).toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.successLight,
                                      ),
                                ),
                                Text(
                                  'Total Spent',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondaryLight,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Purchased Products
                      Text(
                        'Purchased Products',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      SizedBox(height: 2.h),

                      if (productsList.isEmpty) ...[
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Text(
                              'No products found',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryLight,
                                  ),
                            ),
                          ),
                        ),
                      ] else ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: productsList.length,
                          itemBuilder: (context, index) {
                            final product = productsList[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 2.h),
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.dividerLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['productName'] as String,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          '${product['totalQuantity']} purchased • ₱${(product['totalSpent'] as double).toStringAsFixed(2)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color:
                                                    AppTheme.textSecondaryLight,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Re-purchase Button
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _rePurchaseProduct(product),
                                    icon: CustomIconWidget(
                                      iconName: 'add_shopping_cart',
                                      color: Colors.white,
                                      size: 4.w,
                                    ),
                                    label: Text(
                                      'Buy Again',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryLight,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                        vertical: 1.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rePurchaseProduct(Map<String, dynamic> product) async {
    Navigator.pop(context); // Close the dialog

    try {
      // Get the product details from database
      final productService = ProductService();
      final productModel =
          await productService.getProductById(product['productId'] as int);

      if (productModel != null) {
        // Navigate to checkout with this single product
        Navigator.pushNamed(
          context,
          '/checkout',
          arguments: {
            'product': {
              'id': productModel.id,
              'name': productModel.name,
              'sellingPrice': productModel.sellingPrice.toString(),
              'stock': productModel.stock,
              'image': productModel.imagePath,
              'category': productModel.category,
              'description': productModel.description,
            },
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ready to re-purchase ${productModel.name}'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product no longer available'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error re-purchasing product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
