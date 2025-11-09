import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/barcode_scanner_service.dart';

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
    try {
      final barcodeScanner = BarcodeScannerService();
      final scannedBarcode = await barcodeScanner.scanBarcode(context);

      if (scannedBarcode != null) {
        // Validate barcode
        if (barcodeScanner.isValidBarcode(scannedBarcode)) {
          widget.controller.text = scannedBarcode;

          if (mounted) {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Barcode scanned: $scannedBarcode'),
                duration: const Duration(seconds: 2),
                backgroundColor: AppTheme.successLight,
              ),
            );
          }
        } else {
          // Invalid barcode format
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid barcode format: $scannedBarcode'),
                backgroundColor: AppTheme.errorLight,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan barcode: $e'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
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
