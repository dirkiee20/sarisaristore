import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onBarcodePressed;
  final VoidCallback? onFilterPressed;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search products...',
    this.onSearchChanged,
    this.onBarcodePressed,
    this.onFilterPressed,
    this.controller,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchTextChanged() {
    final text = _controller.text;
    setState(() {
      _isSearchActive = text.isNotEmpty;
    });
    widget.onSearchChanged?.call(text);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isLight = brightness == Brightness.light;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLight ? AppTheme.backgroundLight : AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSearchActive
              ? AppTheme.primaryLight
              : (isLight ? AppTheme.dividerLight : AppTheme.dividerDark),
          width: _isSearchActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Search Icon
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: _isSearchActive
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 20,
            ),
          ),

          // Search Input Field
          Expanded(
            child: TextField(
              controller: _controller,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDisabledLight,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 3.h,
                ),
              ),
              onChanged: (value) {
                // onChanged is handled by the listener
              },
            ),
          ),

          // Clear Button (when search is active)
          if (_isSearchActive)
            IconButton(
              onPressed: _clearSearch,
              icon: CustomIconWidget(
                iconName: 'clear',
                color: AppTheme.textSecondaryLight,
                size: 20,
              ),
              constraints: BoxConstraints(
                minWidth: 8.w,
                minHeight: 8.w,
              ),
            ),

          // Barcode Scanner Button
          IconButton(
            onPressed: widget.onBarcodePressed,
            icon: CustomIconWidget(
              iconName: 'qr_code_scanner',
              color: AppTheme.primaryLight,
              size: 22,
            ),
            tooltip: 'Scan Barcode',
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 8.w,
            ),
          ),

          // Filter Button
          IconButton(
            onPressed: widget.onFilterPressed,
            icon: CustomIconWidget(
              iconName: 'tune',
              color: AppTheme.primaryLight,
              size: 22,
            ),
            tooltip: 'Filter Products',
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 8.w,
            ),
          ),

          SizedBox(width: 1.w),
        ],
      ),
    );
  }
}
