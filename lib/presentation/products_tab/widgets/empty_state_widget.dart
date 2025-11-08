import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final String? illustrationUrl;

  const EmptyStateWidget({
    super.key,
    this.title = 'No Products Found',
    this.subtitle =
        'Start building your inventory by adding your first product',
    this.buttonText = 'Add Your First Product',
    this.onButtonPressed,
    this.illustrationUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 60.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: isLight
                    ? AppTheme.primaryLight.withValues(alpha: 0.05)
                    : AppTheme.primaryDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: illustrationUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomImageWidget(
                        imageUrl: illustrationUrl!,
                        width: 60.w,
                        height: 30.h,
                        fit: BoxFit.cover,
                        semanticLabel:
                            "Empty state illustration showing a person organizing products on shelves",
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'inventory_2',
                          color: isLight
                              ? AppTheme.primaryLight.withValues(alpha: 0.3)
                              : AppTheme.primaryDark.withValues(alpha: 0.5),
                          size: 80,
                        ),
                        SizedBox(height: 2.h),
                        CustomIconWidget(
                          iconName: 'add_circle_outline',
                          color: isLight
                              ? AppTheme.primaryLight.withValues(alpha: 0.5)
                              : AppTheme.primaryDark.withValues(alpha: 0.7),
                          size: 40,
                        ),
                      ],
                    ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Subtitle
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isLight
                    ? AppTheme.textSecondaryLight
                    : AppTheme.textSecondaryDark,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      buttonText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Secondary Action
            TextButton(
              onPressed: () {
                // Show help or tutorial
                _showHelpDialog(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'help_outline',
                    color: AppTheme.textSecondaryLight,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Need help getting started?',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'lightbulb_outline',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Getting Started'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              context,
              icon: 'add_box',
              title: 'Add Products',
              description:
                  'Tap the + button to add your first product with details like name, price, and stock.',
            ),
            SizedBox(height: 2.h),
            _buildHelpItem(
              context,
              icon: 'qr_code_scanner',
              title: 'Scan Barcodes',
              description:
                  'Use the barcode scanner to quickly add products by scanning their barcodes.',
            ),
            SizedBox(height: 2.h),
            _buildHelpItem(
              context,
              icon: 'analytics',
              title: 'Track Performance',
              description:
                  'Monitor your sales, profits, and inventory levels in the Analytics tab.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.primaryLight,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
