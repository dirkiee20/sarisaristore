import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductCardWidget extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStockUpdate;
  final VoidCallback? onAddToCart;
  final bool isInCart;
  final int cartQuantity;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStockUpdate,
    this.onAddToCart,
    this.isInCart = false,
    this.cartQuantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    final stockLevel = (product["stock"] as int?) ?? 0;
    final profitMargin = (product["profitMargin"] as double?) ?? 0.0;
    final isLowStock = stockLevel <= 10;
    final hasGoodMargin = profitMargin >= 20.0;

    return Dismissible(
      key: Key('product_${product["id"]}'),
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.successLight,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'add_box',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Update Stock',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'delete',
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Delete',
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onStockUpdate?.call();
          return false;
        } else {
          return await _showDeleteConfirmation(context);
        }
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isLight
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.surface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: (product["image"] as String?) ?? "",
                      width: 16.w,
                      height: 16.w,
                      fit: BoxFit.cover,
                      semanticLabel: (product["semanticLabel"] as String?) ??
                          "Product image",
                    ),
                  ),
                ),
                SizedBox(width: 4.w),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (product["name"] as String?) ?? "Unknown Product",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isLowStock)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.errorLight.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Low Stock',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.errorLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 1.h),

                      Row(
                        children: [
                          // Stock Level
                          CustomIconWidget(
                            iconName: 'inventory_2',
                            color: isLowStock
                                ? AppTheme.errorLight
                                : AppTheme.textSecondaryLight,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '$stockLevel in stock',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isLowStock
                                  ? AppTheme.errorLight
                                  : AppTheme.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4.w),

                          // Selling Price
                          CustomIconWidget(
                            iconName: 'attach_money',
                            color: AppTheme.textSecondaryLight,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            (product["sellingPrice"] as String?) ?? "₱0.00",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),

                      // Profit Margin
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'trending_up',
                            color: hasGoodMargin
                                ? AppTheme.successLight
                                : AppTheme.warningLight,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${profitMargin.toStringAsFixed(1)}% profit',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: hasGoodMargin
                                  ? AppTheme.successLight
                                  : AppTheme.warningLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cart Button
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          onPressed: stockLevel > 0 ? onAddToCart : null,
                          icon: CustomIconWidget(
                            iconName:
                                isInCart ? 'check_circle' : 'shopping_cart',
                            color: stockLevel > 0
                                ? (isInCart
                                    ? AppTheme.successLight
                                    : AppTheme.primaryLight)
                                : AppTheme.textDisabledLight,
                            size: 20,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 8.w,
                            minHeight: 8.w,
                          ),
                          tooltip: isInCart
                              ? 'In Cart ($cartQuantity)'
                              : 'Add to Cart',
                        ),
                        if (isInCart && cartQuantity > 0)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: EdgeInsets.all(0.5.w),
                              decoration: BoxDecoration(
                                color: AppTheme.successLight,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 4.w,
                                minHeight: 4.w,
                              ),
                              child: Text(
                                cartQuantity.toString(),
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // More Options Button
                    IconButton(
                      onPressed: () => _showContextMenu(context),
                      icon: CustomIconWidget(
                        iconName: 'more_vert',
                        color: AppTheme.textSecondaryLight,
                        size: 16,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 6.w,
                        minHeight: 6.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Product'),
            content:
                Text('Are you sure you want to delete "${product["name"]}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onDelete?.call();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorLight,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.primaryLight,
                size: 24,
              ),
              title: const Text('Edit Product'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'add_box',
                color: AppTheme.successLight,
                size: 24,
              ),
              title: const Text('Update Stock'),
              onTap: () {
                Navigator.pop(context);
                onStockUpdate?.call();
              },
            ),
            const Divider(),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: const Text('Delete Product'),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _showDeleteConfirmation(context);
                if (confirmed) {
                  onDelete?.call();
                }
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
