import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const BarcodeScannerWidget({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  bool _isScanning = false;

  Future<void> _scanBarcode() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Simulate barcode scanning with mock data for demonstration
      await Future.delayed(const Duration(seconds: 2));

      // Mock barcode result - in real implementation, use flutter_barcode_scanner
      final mockBarcodes = [
        '1234567890123',
        '9876543210987',
        '5555666677778',
        '1111222233334',
        '9999888877776',
      ];

      final randomBarcode =
          mockBarcodes[DateTime.now().millisecond % mockBarcodes.length];

      widget.controller.text = randomBarcode;

      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barcode scanned: $randomBarcode'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to scan barcode'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Barcode',
          style: AppTheme.lightTheme.textTheme.titleSmall,
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
          ],
          decoration: InputDecoration(
            hintText: 'Enter or scan barcode',
            suffixIcon: Container(
              margin: EdgeInsets.all(1.w),
              child: GestureDetector(
                onTap: _isScanning ? null : _scanBarcode,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _isScanning
                        ? AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3)
                        : AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _isScanning
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
                        : CustomIconWidget(
                            iconName: 'qr_code_scanner',
                            color: Colors.white,
                            size: 5.w,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Tap the scanner icon to scan product barcode',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
