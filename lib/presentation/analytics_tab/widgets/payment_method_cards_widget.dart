import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentMethodCardsWidget extends StatelessWidget {
  final Map<String, double> paymentAmounts;

  const PaymentMethodCardsWidget({
    super.key,
    required this.paymentAmounts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Methods',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildPaymentCard(
                context,
                'Cash',
                'payments',
                paymentAmounts['cash'] ?? 0.0,
                const Color(0xFF27AE60), // Green
              ),
              SizedBox(width: 3.w),
              _buildPaymentCard(
                context,
                'GCash',
                'account_balance_wallet',
                paymentAmounts['gcash'] ?? 0.0,
                const Color(0xFF3498DB), // Blue
              ),
              SizedBox(width: 3.w),
              _buildPaymentCard(
                context,
                'Credit',
                'credit_card',
                paymentAmounts['credit'] ?? 0.0,
                const Color(0xFF9B59B6), // Purple
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    String title,
    String iconName,
    double amount,
    Color cardColor,
  ) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cardColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Text(
              '₱${amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cardColor,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Total Amount',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isLight
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
