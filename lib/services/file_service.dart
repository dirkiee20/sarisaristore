import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling file operations like saving and sharing reports
class FileService {
  /// Get the appropriate directory for storing files
  static Future<Directory> _getStorageDirectory() async {
    if (Platform.isAndroid) {
      // For Android, use external storage (Documents directory)
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final documentsDir = Directory('${directory.path}/Documents');
        if (!await documentsDir.exists()) {
          await documentsDir.create(recursive: true);
        }
        return documentsDir;
      }
    }

    // For iOS and other platforms, use application documents directory
    return await getApplicationDocumentsDirectory();
  }

  /// Request storage permissions for Android
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
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
      return null;
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
