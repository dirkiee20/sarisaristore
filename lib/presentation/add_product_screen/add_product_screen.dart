import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../data/models/product_model.dart';
import '../../services/product_service.dart';
import './widgets/barcode_scanner_widget.dart';
import './widgets/category_picker_widget.dart';
import './widgets/pricing_calculator_widget.dart';
import './widgets/product_image_picker_widget.dart';
import './widgets/stock_quantity_picker_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  // Form state
  String? _selectedCategory;
  XFile? _selectedImage;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _quantityController.text = '0';
    _addFormListeners();
  }

  @override
  void dispose() {
    _removeFormListeners();
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addFormListeners() {
    _nameController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _barcodeController.addListener(_onFormChanged);
    _costController.addListener(_onFormChanged);
    _priceController.addListener(_onFormChanged);
    _quantityController.addListener(_onFormChanged);
  }

  void _removeFormListeners() {
    _nameController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _barcodeController.removeListener(_onFormChanged);
    _costController.removeListener(_onFormChanged);
    _priceController.removeListener(_onFormChanged);
    _quantityController.removeListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {
      _hasUnsavedChanges = true;
      // Rebuild to update button enabled state
    });
  }

  bool _isFormValid() {
    return _nameController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _costController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty &&
        _quantityController.text.trim().isNotEmpty &&
        (double.tryParse(_costController.text) ?? 0) > 0 &&
        (double.tryParse(_priceController.text) ?? 0) > 0 &&
        (int.tryParse(_quantityController.text) ?? 0) >= 0;
  }

  String? _validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    if (value.trim().length < 2) {
      return 'Product name must be at least 2 characters';
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  String? _validateCostPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cost price is required';
    }
    final cost = double.tryParse(value);
    if (cost == null || cost <= 0) {
      return 'Enter a valid cost price';
    }
    return null;
  }

  String? _validateSellingPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Selling price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Enter a valid selling price';
    }
    final cost = double.tryParse(_costController.text) ?? 0;
    if (cost > 0 && price < cost) {
      return 'Selling price should be higher than cost';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stock quantity is required';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 0) {
      return 'Enter a valid quantity';
    }
    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final product = ProductModel(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _selectedCategory!,
        barcode: _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        costPrice: double.parse(_costController.text),
        sellingPrice: double.parse(_priceController.text),
        stock: int.parse(_quantityController.text),
        imagePath: _selectedImage?.path,
      );

      final productService = ProductService();
      await productService.createProduct(product);

      if (mounted) {
        HapticFeedback.mediumImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Product "${_nameController.text.trim()}" added successfully!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successLight,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to stock management tab
        Navigator.pushReplacementNamed(context, '/stock-management-tab');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasUnsavedChanges) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Add Product'),
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isFormValid() && !_isSaving ? _saveProduct : null,
              child: _isSaving
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: _isFormValid() && !_isSaving
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            SizedBox(width: 2.w),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.all(4.w),
            children: [
              // Product Image Section
              ProductImagePickerWidget(
                onImageSelected: (image) {
                  setState(() {
                    _selectedImage = image;
                  });
                  _onFormChanged();
                },
                initialImage: _selectedImage,
              ),

              SizedBox(height: 4.h),

              // Basic Information Card
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Product Name
                    Text(
                      'Product Name *',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _nameController,
                      validator: _validateProductName,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Enter product name',
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Description
                    Text(
                      'Description',
                      style: AppTheme.lightTheme.textTheme.titleSmall,
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Enter product description (optional)',
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Category Picker
                    CategoryPickerWidget(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                        _onFormChanged();
                      },
                      validator: _validateCategory,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Barcode Section
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BarcodeScannerWidget(
                  controller: _barcodeController,
                ),
              ),

              SizedBox(height: 3.h),

              // Pricing Calculator
              PricingCalculatorWidget(
                costController: _costController,
                priceController: _priceController,
                costValidator: _validateCostPrice,
                priceValidator: _validateSellingPrice,
              ),

              SizedBox(height: 3.h),

              // Stock Quantity
              StockQuantityPickerWidget(
                controller: _quantityController,
                validator: _validateQuantity,
              ),

              SizedBox(height: 6.h),

              // Save Button
              ElevatedButton(
                onPressed: _isFormValid() && !_isSaving ? _saveProduct : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          const Text('Saving Product...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'add',
                            color: Colors.white,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          const Text('Add Product'),
                        ],
                      ),
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
