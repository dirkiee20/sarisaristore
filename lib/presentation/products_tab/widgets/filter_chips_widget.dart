    import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final ValueChanged<String?>? onCategorySelected;

  const FilterChipsWidget({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      height: 6.h,
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: categories.length + 1, // +1 for "All" chip
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" chip
            final isSelected = selectedCategory == null;
            return _buildFilterChip(
              context,
              label: 'All',
              count: _getTotalProductCount(),
              isSelected: isSelected,
              onTap: () => onCategorySelected?.call(null),
              isLight: isLight,
            );
          }

          final category = categories[index - 1];
          final categoryName = (category["name"] as String?) ?? "";
          final productCount = (category["count"] as int?) ?? 0;
          final isSelected = selectedCategory == categoryName;

          return _buildFilterChip(
            context,
            label: categoryName,
            count: productCount,
            isSelected: isSelected,
            onTap: () => onCategorySelected?.call(categoryName),
            isLight: isLight,
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLight,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryLight
                : (isLight ? AppTheme.surfaceLight : AppTheme.surfaceDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryLight
                  : (isLight ? AppTheme.dividerLight : AppTheme.dividerDark),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryLight.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isLight
                          ? AppTheme.textPrimaryLight
                          : AppTheme.textPrimaryDark),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count > 0) ...[
                SizedBox(width: 1.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppTheme.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected ? Colors.white : AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _getTotalProductCount() {
    return categories.fold<int>(0, (sum, category) {
      return sum + ((category["count"] as int?) ?? 0);
    });
  }
}
