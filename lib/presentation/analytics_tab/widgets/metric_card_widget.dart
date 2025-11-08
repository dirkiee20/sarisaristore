import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MetricCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double? changePercentage;
  final bool isPositive;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const MetricCardWidget({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.changePercentage,
    this.isPositive = true,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75.w,
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.only(right: 3.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  isLight ? const Color(0x0A000000) : const Color(0x1A000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isLight ? const Color(0xFF7F8C8D) : const Color(0xFFBDC3C7),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 0.5.h),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isLight
                      ? const Color(0xFF95A5A6)
                      : const Color(0xFF95A5A6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (changePercentage != null) ...[
              SizedBox(height: 1.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: isPositive ? 'trending_up' : 'trending_down',
                    color: isPositive
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFE74C3C),
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Flexible(
                    child: Text(
                      '${isPositive ? '+' : ''}${changePercentage!.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPositive
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFE74C3C),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
