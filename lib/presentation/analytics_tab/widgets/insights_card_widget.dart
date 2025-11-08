import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class InsightsCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InsightsCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.iconName,
    this.iconColor,
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
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLight ? const Color(0x1A2C3E50) : const Color(0x1AFFFFFF),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF3498DB))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: iconColor ?? const Color(0xFF3498DB),
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isLight
                          ? const Color(0xFF7F8C8D)
                          : const Color(0xFFBDC3C7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'chevron_right',
                color:
                    isLight ? const Color(0xFF95A5A6) : const Color(0xFF95A5A6),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
