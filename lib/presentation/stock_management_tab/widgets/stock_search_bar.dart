import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StockSearchBar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onScanBarcode;
  final String sortBy;
  final ValueChanged<String> onSortChanged;

  const StockSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onScanBarcode,
    required this.sortBy,
    required this.onSortChanged,
  });

  @override
  State<StockSearchBar> createState() => _StockSearchBarState();
}

class _StockSearchBarState extends State<StockSearchBar> {
  late TextEditingController _searchController;
  bool _isSearchFocused = false;

  final List<Map<String, String>> _sortOptions = [
    {'value': 'name', 'label': 'Name A-Z'},
    {'value': 'stock_low', 'label': 'Stock (Low to High)'},
    {'value': 'stock_high', 'label': 'Stock (High to Low)'},
    {'value': 'status', 'label': 'Stock Status'},
    {'value': 'category', 'label': 'Category'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search row
          Row(
            children: [
              // Search field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSearchFocused
                          ? AppTheme.primaryLight
                          : AppTheme.dividerLight,
                      width: _isSearchFocused ? 2 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    onTap: () => setState(() => _isSearchFocused = true),
                    onEditingComplete: () =>
                        setState(() => _isSearchFocused = false),
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search products by name or barcode...',
                      hintStyle:
                          AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDisabledLight,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'search',
                          color: AppTheme.textSecondaryLight,
                          size: 20,
                        ),
                      ),
                      suffixIcon: widget.searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                widget.onSearchChanged('');
                              },
                              icon: CustomIconWidget(
                                iconName: 'clear',
                                color: AppTheme.textSecondaryLight,
                                size: 20,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              // Barcode scan button
              GestureDetector(
                onTap: widget.onScanBarcode,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'qr_code_scanner',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Sort and filter row
          Row(
            children: [
              // Sort dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.dividerLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.sortBy,
                      isExpanded: true,
                      icon: CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: AppTheme.textSecondaryLight,
                        size: 20,
                      ),
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                      items: _sortOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option['value'],
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: _getSortIcon(option['value']!),
                                color: AppTheme.textSecondaryLight,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                option['label']!,
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onSortChanged(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              // Quick actions button
              GestureDetector(
                onTap: () => _showQuickActions(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.dividerLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'tune',
                        color: AppTheme.textSecondaryLight,
                        size: 20,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Actions',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSortIcon(String sortValue) {
    switch (sortValue) {
      case 'name':
        return 'sort_by_alpha';
      case 'stock_low':
      case 'stock_high':
        return 'inventory';
      case 'status':
        return 'circle';
      case 'category':
        return 'category';
      default:
        return 'sort';
    }
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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

            Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),

            // Action items
            _buildActionItem(
              'Bulk Stock Update',
              'Update multiple products at once',
              'edit',
              () {
                Navigator.pop(context);
                // Navigate to bulk update screen
              },
            ),
            _buildActionItem(
              'Export Stock Report',
              'Download current stock levels',
              'download',
              () {
                Navigator.pop(context);
                // Export functionality
              },
            ),
            _buildActionItem(
              'Low Stock Alert Settings',
              'Configure reorder level alerts',
              'notifications',
              () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
      String title, String subtitle, String iconName, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: iconName,
            color: AppTheme.primaryLight,
            size: 20,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondaryLight,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.textSecondaryLight,
        size: 20,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
