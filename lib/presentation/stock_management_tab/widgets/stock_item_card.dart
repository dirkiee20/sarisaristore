import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../data/models/product_model.dart';

class StockItemCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onStockAdjustment;
  final VoidCallback? onReorder;
  final VoidCallback? onTap;
  final bool isSelected;

  const StockItemCard({
    super.key,
    required this.product,
    this.onStockAdjustment,
    this.onReorder,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentStock = product.stock;
    final reorderLevel = 10; // Using default reorder level
    final stockStatus = _getStockStatus(currentStock, reorderLevel);
    final statusColor = _getStatusColor(stockStatus);
    final isLowStock =
        stockStatus == 'Low Stock' || stockStatus == 'Out of Stock';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(product.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onStockAdjustment?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Adjust',
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onReorder?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: Colors.white,
              icon: Icons.shopping_cart,
              label: 'Reorder',
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => onTap?.call(),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isLowStock)
                                Container(
                                  margin: EdgeInsets.only(left: 2.w),
                                  child: CustomIconWidget(
                                    iconName: 'warning',
                                    color: AppTheme.errorLight,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            product.category,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        stockStatus,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildStockInfo(
                        'Current Stock',
                        currentStock.toString(),
                        CustomIconWidget(
                          iconName: 'inventory',
                          color: AppTheme.textSecondaryLight,
                          size: 16,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 4.h,
                      color: AppTheme.dividerLight,
                    ),
                    Expanded(
                      child: _buildStockInfo(
                        'Reorder Level',
                        reorderLevel.toString(),
                        CustomIconWidget(
                          iconName: 'refresh',
                          color: AppTheme.textSecondaryLight,
                          size: 16,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 4.h,
                      color: AppTheme.dividerLight,
                    ),
                    Expanded(
                      child: _buildStockInfo(
                        'Unit Price',
                        '₱${product.sellingPrice.toStringAsFixed(2)}',
                        CustomIconWidget(
                          iconName: 'attach_money',
                          color: AppTheme.textSecondaryLight,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLowStock) ...[
                  SizedBox(height: 2.h),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppTheme.errorLight.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          color: AppTheme.errorLight,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            stockStatus == 'Out of Stock'
                                ? 'This product is out of stock and needs immediate restocking'
                                : 'Stock level is below reorder point. Consider restocking soon',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.errorLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockInfo(String label, String value, Widget icon) {
    return Column(
      children: [
        icon,
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getStockStatus(int currentStock, int reorderLevel) {
    if (currentStock == 0) return 'Out of Stock';
    if (currentStock <= reorderLevel) return 'Low Stock';
    return 'In Stock';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Out of Stock':
        return AppTheme.errorLight;
      case 'Low Stock':
        return AppTheme.warningLight;
      case 'In Stock':
        return AppTheme.successLight;
      default:
        return AppTheme.textSecondaryLight;
    }
  }
}
