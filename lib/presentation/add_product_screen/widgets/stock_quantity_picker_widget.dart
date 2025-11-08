import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StockQuantityPickerWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const StockQuantityPickerWidget({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  State<StockQuantityPickerWidget> createState() =>
      _StockQuantityPickerWidgetState();
}

class _StockQuantityPickerWidgetState extends State<StockQuantityPickerWidget> {
  void _incrementQuantity() {
    final currentValue = int.tryParse(widget.controller.text) ?? 0;
    final newValue = currentValue + 1;
    widget.controller.text = newValue.toString();
    HapticFeedback.lightImpact();
  }

  void _decrementQuantity() {
    final currentValue = int.tryParse(widget.controller.text) ?? 0;
    if (currentValue > 0) {
      final newValue = currentValue - 1;
      widget.controller.text = newValue.toString();
      HapticFeedback.lightImpact();
    }
  }

  void _showQuantityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        height: 40.h,
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Set Stock Quantity',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 4.h),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildQuantityButton(
                    icon: 'remove',
                    onTap: _decrementQuantity,
                    isEnabled: (int.tryParse(widget.controller.text) ?? 0) > 0,
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 30.w,
                    child: TextFormField(
                      controller: widget.controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      style: AppTheme.lightTheme.textTheme.headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildQuantityButton(
                    icon: 'add',
                    onTap: _incrementQuantity,
                    isEnabled: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required String icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: isEnabled
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.outline,
            size: 6.w,
          ),
        ),
      ),
    );
  }

  Color _getStockStatusColor() {
    final quantity = int.tryParse(widget.controller.text) ?? 0;
    if (quantity == 0) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (quantity < 10) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.successLight;
    }
  }

  String _getStockStatus() {
    final quantity = int.tryParse(widget.controller.text) ?? 0;
    if (quantity == 0) {
      return 'Out of Stock';
    } else if (quantity < 5) {
      return 'Very Low Stock';
    } else if (quantity < 10) {
      return 'Low Stock';
    } else if (quantity < 50) {
      return 'Good Stock';
    } else {
      return 'High Stock';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Quantity *',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.validator != null &&
                      widget.validator!(widget.controller.text) != null
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildQuantityButton(
                    icon: 'remove',
                    onTap: _decrementQuantity,
                    isEnabled: (int.tryParse(widget.controller.text) ?? 0) > 0,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showQuantityPicker,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
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
                              widget.controller.text.isEmpty
                                  ? '0'
                                  : widget.controller.text,
                              style: AppTheme.lightTheme.textTheme.headlineSmall
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
                    ),
                  ),
                  _buildQuantityButton(
                    icon: 'add',
                    onTap: _incrementQuantity,
                    isEnabled: true,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getStockStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStockStatusColor().withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: (int.tryParse(widget.controller.text) ?? 0) > 10
                          ? 'inventory'
                          : 'warning',
                      color: _getStockStatusColor(),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _getStockStatus(),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getStockStatusColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.validator != null &&
            widget.validator!(widget.controller.text) != null) ...[
          SizedBox(height: 1.h),
          Text(
            widget.validator!(widget.controller.text)!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
        SizedBox(height: 1.h),
        Text(
          'Tap the quantity box to open number picker or use +/- buttons',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
