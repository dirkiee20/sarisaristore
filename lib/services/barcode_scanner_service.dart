import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling barcode scanning functionality
class BarcodeScannerService {
  static final BarcodeScannerService _instance =
      BarcodeScannerService._internal();
  factory BarcodeScannerService() => _instance;
  BarcodeScannerService._internal();

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Open camera permission settings
  Future<void> openPermissionSettings() async {
    await openAppSettings();
  }

  /// Scan barcode and return the result
  Future<String?> scanBarcode(BuildContext context) async {
    // Check permission first
    if (!await hasCameraPermission()) {
      final granted = await requestCameraPermission();
      if (!granted) {
        // Show permission dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
              'Camera permission is required to scan barcodes. Please grant permission in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openPermissionSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return null;
      }
    }

    // Show scanner dialog
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _BarcodeScannerDialog(),
    );

    return result;
  }

  /// Validate barcode format
  bool isValidBarcode(String barcode) {
    // Basic validation - barcode should not be empty and contain only valid characters
    if (barcode.isEmpty) return false;

    // Check for common barcode formats (EAN-13, UPC-A, etc.)
    final RegExp barcodeRegex = RegExp(r'^[0-9]{8,18}$');
    return barcodeRegex.hasMatch(barcode);
  }

  /// Get barcode type from raw value
  String getBarcodeType(String barcode) {
    final length = barcode.length;

    switch (length) {
      case 8:
        return 'EAN-8';
      case 12:
        return 'UPC-A';
      case 13:
        return 'EAN-13';
      case 14:
        return 'EAN-14';
      default:
        return 'Unknown';
    }
  }
}

/// Dialog widget for barcode scanning
class _BarcodeScannerDialog extends StatefulWidget {
  const _BarcodeScannerDialog();

  @override
  State<_BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<_BarcodeScannerDialog> {
  final MobileScannerController controller = MobileScannerController(
    formats: [
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE
    ],
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Scan Barcode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Position the barcode within the frame to scan',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Scanner view
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MobileScanner(
                    controller: controller,
                    onDetect: (capture) {
                      if (!_isScanning) return;

                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final barcode = barcodes.first;
                        if (barcode.rawValue != null) {
                          _onBarcodeDetected(barcode.rawValue!);
                        }
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.toggleTorch(),
                  icon: const Icon(Icons.flashlight_on),
                  label: const Text('Torch'),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.switchCamera(),
                  icon: const Icon(Icons.cameraswitch),
                  label: const Text('Switch'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onBarcodeDetected(String barcode) {
    setState(() {
      _isScanning = false;
    });

    // Provide haptic feedback
    // HapticFeedback.mediumImpact();

    // Close dialog and return result
    Navigator.pop(context, barcode);
  }
}
