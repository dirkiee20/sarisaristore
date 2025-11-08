import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class StockFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final Map<String, int> filterCounts;

  const StockFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterCounts,
  });

  static const List<String> _filters = [
    'All',
    'In Stock',
    'Low Stock',
    'Out of Stock',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = selectedFilter == filter;
          final count = filterCounts[filter] ?? 0;

          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color:
                          isSelected ? Colors.white : AppTheme.textPrimaryLight,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (count > 0) ...[
                    SizedBox(width: 1.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w, vertical: 0.2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.3)
                            : AppTheme.textSecondaryLight
                                .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              onSelected: (selected) {
                if (selected) {
                  onFilterChanged(filter);
                }
              },
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              selectedColor: _getFilterColor(filter),
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? _getFilterColor(filter)
                    : AppTheme.dividerLight,
                width: 1,
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Out of Stock':
        return AppTheme.errorLight;
      case 'Low Stock':
        return AppTheme.warningLight;
      case 'In Stock':
        return AppTheme.successLight;
      default:
        return AppTheme.primaryLight;
    }
  }
}
