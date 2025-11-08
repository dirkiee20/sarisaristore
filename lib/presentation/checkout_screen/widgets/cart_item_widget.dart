import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../data/models/product_model.dart';

class CartItemWidget extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = product.sellingPrice * quantity;

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and remove button
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.errorLight,
                    size: 5.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            // Price and quantity controls
            Row(
              children: [
                // Quantity controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.dividerLight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          onQuantityChanged(quantity - 1);
                          HapticFeedback.lightImpact();
                        },
                        icon: CustomIconWidget(
                          iconName: 'remove',
                          color: AppTheme.textPrimaryLight,
                          size: 4.w,
                        ),
                        padding: EdgeInsets.all(1.w),
                        constraints: const BoxConstraints(),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text(
                          quantity.toString(),
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: quantity < product.stock
                            ? () {
                                onQuantityChanged(quantity + 1);
                                HapticFeedback.lightImpact();
                              }
                            : null,
                        icon: CustomIconWidget(
                          iconName: 'add',
                          color: quantity < product.stock
                              ? AppTheme.textPrimaryLight
                              : AppTheme.textDisabledLight,
                          size: 4.w,
                        ),
                        padding: EdgeInsets.all(1.w),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Subtotal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₱${product.sellingPrice.toStringAsFixed(2)} × $quantity',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '₱${subtotal.toStringAsFixed(2)}',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

