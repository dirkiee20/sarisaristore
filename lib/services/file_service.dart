import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Service for handling file operations like saving and sharing reports
class FileService {
  /// Check if device supports scoped storage (Android 10+)
  static Future<bool> _supportsScopedStorage() async {
    if (!Platform.isAndroid) return false;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 29; // Android 10 (API 29)
  }

  /// Get the appropriate directory for storing files
  static Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid && await _supportsScopedStorage()) {
      // For Android 10+, try to use Downloads directory via Media Store
      try {
        return await _getDownloadsDirectory();
      } catch (e) {
        // Fallback to app-private directory if Downloads fails
        return await _getAppPrivateDirectory();
      }
    } else {
      // For older Android versions or other platforms, use app-private directory
      return await _getAppPrivateDirectory();
    }
  }

  /// Get Downloads directory for Android 10+ using Media Store approach
  static Future<Directory> _getDownloadsDirectory() async {
    // For now, we'll use a simplified approach
    // In a production app, you'd use platform channels to access Media Store
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final downloadsDir = Directory('${directory.path}/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      return downloadsDir;
    }
    throw Exception('Cannot access Downloads directory');
  }

  /// Get app-private directory as fallback
  static Future<Directory> _getAppPrivateDirectory() async {
    final directory = await getApplicationDocumentsDirectory();

    // Create a Reports subdirectory for organization
    final reportsDir = Directory('${directory.path}/Reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    return reportsDir;
  }

  /// Request storage permissions for Android
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final supportsScoped = await _supportsScopedStorage();
      if (supportsScoped) {
        // For Android 10+, we might need MANAGE_EXTERNAL_STORAGE
        // but for now we'll try without it
        return true;
      }
    }
    return true; // iOS doesn't need explicit permission for documents directory
  }

  /// Save report content to a file and return the file path
  static Future<String?> saveReportToFile(
    String content,
    String fileName,
    String extension,
  ) async {
    try {
      // Request permissions first
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final directory = await _getStorageDirectory();
      final filePath = '${directory.path}/$fileName.$extension';

      final file = File(filePath);
      await file.writeAsString(content);

      return filePath;
    } catch (e) {
      print('Error saving file: $e');
      // Try fallback to app-private directory if external storage fails
      try {
        final fallbackDir = await _getAppPrivateDirectory();
        final fallbackPath = '${fallbackDir.path}/$fileName.$extension';

        final file = File(fallbackPath);
        await file.writeAsString(content);

        return fallbackPath;
      } catch (fallbackError) {
        print('Fallback save also failed: $fallbackError');
        return null;
      }
    }
  }

  /// Share a file using the system's share dialog
  static Future<void> shareFile(String filePath, String title) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles([file], text: title);
    } catch (e) {
      print('Error sharing file: $e');
      throw Exception('Failed to share file: $e');
    }
  }

  /// Generate CSV content from data
  static String generateCSV(
      List<Map<String, dynamic>> data, List<String> headers) {
    final buffer = StringBuffer();

    // Add headers
    buffer.writeln(headers.join(','));

    // Add data rows
    for (final row in data) {
      final values = headers.map((header) {
        final value = row[header]?.toString() ?? '';
        // Escape quotes and wrap in quotes if contains comma or quote
        if (value.contains(',') ||
            value.contains('"') ||
            value.contains('\n')) {
          return '"${value.replaceAll('"', '""')}"';
        }
        return value;
      });
      buffer.writeln(values.join(','));
    }

    return buffer.toString();
  }

  /// Generate JSON content from data
  static String generateJSON(List<Map<String, dynamic>> data) {
    // Simple JSON generation - in a real app you might use json.encode
    final buffer = StringBuffer();
    buffer.writeln('[');

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      buffer.writeln('  {');

      final entries = item.entries.toList();
      for (int j = 0; j < entries.length; j++) {
        final entry = entries[j];
        final value = entry.value;
        final isLast = j == entries.length - 1;

        if (value is String) {
          buffer.write('    "${entry.key}": "${value.replaceAll('"', '\\"')}"');
        } else {
          buffer.write('    "${entry.key}": $value');
        }

        if (!isLast) buffer.write(',');
        buffer.writeln();
      }

      buffer.write('  }');
      if (i < data.length - 1) buffer.writeln(',');
    }

    buffer.writeln();
    buffer.writeln(']');
    return buffer.toString();
  }
}
