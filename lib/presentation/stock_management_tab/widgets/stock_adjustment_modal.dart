import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../data/models/product_model.dart';

class StockAdjustmentModal extends StatefulWidget {
  final ProductModel product;
  final Function(int newStock, String reason) onStockUpdated;

  const StockAdjustmentModal({
    super.key,
    required this.product,
    required this.onStockUpdated,
  });

  @override
  State<StockAdjustmentModal> createState() => _StockAdjustmentModalState();
}

class _StockAdjustmentModalState extends State<StockAdjustmentModal> {
  late int _currentStock;
  late int _newStock;
  late TextEditingController _stockController;
  String _selectedReason = 'Manual Adjustment';
  final TextEditingController _customReasonController = TextEditingController();

  final List<String> _adjustmentReasons = [
    'Manual Adjustment',
    'Inventory Count',
    'Damaged Goods',
    'Expired Items',
    'Theft/Loss',
    'Supplier Return',
    'Customer Return',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _currentStock = widget.product.stock;
    _newStock = _currentStock;
    _stockController = TextEditingController(text: _newStock.toString());
  }

  @override
  void dispose() {
    _stockController.dispose();
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final difference = _newStock - _currentStock;
    final isDifferencePositive = difference > 0;

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adjust Stock',
                      style:
                          AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      widget.product.name,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.textSecondaryLight,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Current stock info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'inventory',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Current Stock: $_currentStock units',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Stock adjustment controls
          Text(
            'New Stock Level',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Number picker with +/- buttons
          Row(
            children: [
              // Decrease button
              GestureDetector(
                onTap: () {
                  if (_newStock > 0) {
                    setState(() {
                      _newStock--;
                      _stockController.text = _newStock.toString();
                    });
                    HapticFeedback.lightImpact();
                  }
                },
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    border: Border.all(color: AppTheme.dividerLight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'remove',
                      color: AppTheme.textPrimaryLight,
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),

              // Stock input field
              Expanded(
                child: TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: EdgeInsets.symmetric(vertical: 3.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.dividerLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.dividerLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: AppTheme.primaryLight, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    final newValue = int.tryParse(value) ?? 0;
                    setState(() {
                      _newStock = newValue;
                    });
                  },
                ),
              ),
              SizedBox(width: 4.w),

              // Increase button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _newStock++;
                    _stockController.text = _newStock.toString();
                  });
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    border: Border.all(color: AppTheme.dividerLight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.textPrimaryLight,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Difference indicator
          if (difference != 0)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDifferencePositive
                    ? AppTheme.successLight.withValues(alpha: 0.1)
                    : AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDifferencePositive
                      ? AppTheme.successLight.withValues(alpha: 0.3)
                      : AppTheme.errorLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName:
                        isDifferencePositive ? 'trending_up' : 'trending_down',
                    color: isDifferencePositive
                        ? AppTheme.successLight
                        : AppTheme.errorLight,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    '${isDifferencePositive ? '+' : ''}$difference units',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: isDifferencePositive
                          ? AppTheme.successLight
                          : AppTheme.errorLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 3.h),

          // Adjustment reason
          Text(
            'Reason for Adjustment',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          DropdownButtonFormField<String>(
            initialValue: _selectedReason,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.dividerLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.dividerLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryLight, width: 2),
              ),
            ),
            items: _adjustmentReasons.map((reason) {
              return DropdownMenuItem(
                value: reason,
                child: Text(
                  reason,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedReason = value ?? 'Manual Adjustment';
              });
            },
          ),

          // Custom reason field
          if (_selectedReason == 'Other') ...[
            SizedBox(height: 2.h),
            TextFormField(
              controller: _customReasonController,
              decoration: InputDecoration(
                hintText: 'Enter custom reason...',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.dividerLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.dividerLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppTheme.primaryLight, width: 2),
                ),
              ),
            ),
          ],
          SizedBox(height: 4.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    side: BorderSide(color: AppTheme.dividerLight),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: difference != 0 ? _handleStockUpdate : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Update Stock',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  void _handleStockUpdate() {
    final reason = _selectedReason == 'Other'
        ? _customReasonController.text.trim()
        : _selectedReason;

    if (reason.isEmpty && _selectedReason == 'Other') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason for the adjustment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onStockUpdated(_newStock, reason);
    Navigator.pop(context);

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stock updated successfully'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }
}
