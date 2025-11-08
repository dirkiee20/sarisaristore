import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PricingCalculatorWidget extends StatefulWidget {
  final TextEditingController costController;
  final TextEditingController priceController;
  final String? Function(String?)? costValidator;
  final String? Function(String?)? priceValidator;

  const PricingCalculatorWidget({
    super.key,
    required this.costController,
    required this.priceController,
    this.costValidator,
    this.priceValidator,
  });

  @override
  State<PricingCalculatorWidget> createState() =>
      _PricingCalculatorWidgetState();
}

class _PricingCalculatorWidgetState extends State<PricingCalculatorWidget> {
  double _profitMargin = 0.0;
  double _profitAmount = 0.0;

  @override
  void initState() {
    super.initState();
    widget.costController.addListener(_calculateProfit);
    widget.priceController.addListener(_calculateProfit);
    _calculateProfit();
  }

  @override
  void dispose() {
    widget.costController.removeListener(_calculateProfit);
    widget.priceController.removeListener(_calculateProfit);
    super.dispose();
  }

  void _calculateProfit() {
    final cost = double.tryParse(widget.costController.text) ?? 0.0;
    final price = double.tryParse(widget.priceController.text) ?? 0.0;

    if (cost > 0 && price > 0) {
      final profit = price - cost;
      final margin = (profit / price) * 100;

      setState(() {
        _profitAmount = profit;
        _profitMargin = margin;
      });
    } else {
      setState(() {
        _profitAmount = 0.0;
        _profitMargin = 0.0;
      });
    }
  }

  Color _getProfitColor() {
    if (_profitMargin <= 0) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (_profitMargin < 20) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.successLight;
    }
  }

  String _getProfitStatus() {
    if (_profitMargin <= 0) {
      return 'Loss';
    } else if (_profitMargin < 10) {
      return 'Low Profit';
    } else if (_profitMargin < 20) {
      return 'Fair Profit';
    } else if (_profitMargin < 30) {
      return 'Good Profit';
    } else {
      return 'High Profit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Information',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cost Price *',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: widget.costController,
                      validator: widget.costValidator,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '₱ ',
                        prefixStyle: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selling Price *',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: widget.priceController,
                      validator: widget.priceValidator,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '₱ ',
                        prefixStyle: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _getProfitColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getProfitColor().withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profit Amount',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '₱ ${_profitAmount.toStringAsFixed(2)}',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: _getProfitColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Profit Margin',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${_profitMargin.toStringAsFixed(1)}%',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: _getProfitColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: _getProfitColor(),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: _profitMargin > 0
                                ? 'trending_up'
                                : 'trending_down',
                            color: Colors.white,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _getProfitStatus(),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Tip: Aim for 20-30% profit margin for healthy business growth',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
