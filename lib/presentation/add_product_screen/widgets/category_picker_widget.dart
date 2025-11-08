import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryPickerWidget extends StatefulWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;
  final String? Function(String?)? validator;

  const CategoryPickerWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.validator,
  });

  @override
  State<CategoryPickerWidget> createState() => _CategoryPickerWidgetState();
}

class _CategoryPickerWidgetState extends State<CategoryPickerWidget> {
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food & Beverages',
      'icon': 'restaurant',
      'subcategories': [
        'Snacks',
        'Drinks',
        'Canned Goods',
        'Instant Noodles',
        'Rice & Grains'
      ]
    },
    {
      'name': 'Personal Care',
      'icon': 'face',
      'subcategories': [
        'Soap & Shampoo',
        'Toothpaste',
        'Deodorant',
        'Skincare',
        'Feminine Care'
      ]
    },
    {
      'name': 'Household Items',
      'icon': 'home',
      'subcategories': [
        'Cleaning Supplies',
        'Detergent',
        'Kitchen Utensils',
        'Storage',
        'Batteries'
      ]
    },
    {
      'name': 'School & Office',
      'icon': 'school',
      'subcategories': [
        'Notebooks',
        'Pens & Pencils',
        'Paper',
        'Folders',
        'Calculators'
      ]
    },
    {
      'name': 'Electronics',
      'icon': 'electrical_services',
      'subcategories': [
        'Phone Accessories',
        'Chargers',
        'Earphones',
        'Memory Cards',
        'Cables'
      ]
    },
    {
      'name': 'Clothing',
      'icon': 'checkroom',
      'subcategories': ['T-shirts', 'Underwear', 'Socks', 'Caps', 'Slippers']
    },
    {
      'name': 'Medicine',
      'icon': 'medical_services',
      'subcategories': [
        'Pain Relief',
        'Vitamins',
        'First Aid',
        'Cough & Cold',
        'Antiseptic'
      ]
    },
    {
      'name': 'Tobacco & Alcohol',
      'icon': 'smoking_rooms',
      'subcategories': ['Cigarettes', 'Beer', 'Liquor', 'Wine', 'Vape Products']
    },
    {
      'name': 'Others',
      'icon': 'category',
      'subcategories': [
        'Toys',
        'Games',
        'Gifts',
        'Seasonal Items',
        'Miscellaneous'
      ]
    },
  ];

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
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
                'Select Category',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected =
                        widget.selectedCategory == category['name'];

                    return Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      child: InkWell(
                        onTap: () {
                          widget.onCategorySelected(category['name'] as String);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.lightTheme.colorScheme.primary
                                      : AppTheme.lightTheme.colorScheme.outline
                                          .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: category['icon'] as String,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme
                                            .lightTheme.colorScheme.outline,
                                    size: 6.w,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category['name'] as String,
                                      style: AppTheme
                                          .lightTheme.textTheme.titleSmall
                                          ?.copyWith(
                                        color: isSelected
                                            ? AppTheme
                                                .lightTheme.colorScheme.primary
                                            : AppTheme.lightTheme.colorScheme
                                                .onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      (category['subcategories']
                                              as List<String>)
                                          .take(3)
                                          .join(', '),
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.outline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                CustomIconWidget(
                                  iconName: 'check_circle',
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  size: 6.w,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _showCategoryPicker,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.validator != null &&
                        widget.validator!(widget.selectedCategory) != null
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (widget.selectedCategory != null) ...[
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: _categories.firstWhere(
                          (cat) => cat['name'] == widget.selectedCategory,
                          orElse: () => {'icon': 'category'},
                        )['icon'] as String,
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                ],
                Expanded(
                  child: Text(
                    widget.selectedCategory ?? 'Select category',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: widget.selectedCategory != null
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: AppTheme.lightTheme.colorScheme.outline,
                  size: 6.w,
                ),
              ],
            ),
          ),
        ),
        if (widget.validator != null &&
            widget.validator!(widget.selectedCategory) != null) ...[
          SizedBox(height: 1.h),
          Text(
            widget.validator!(widget.selectedCategory)!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
