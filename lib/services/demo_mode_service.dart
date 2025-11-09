import 'package:flutter/material.dart';

/// Service for managing global demo mode state across the entire app
class DemoModeService extends ChangeNotifier {
  static final DemoModeService _instance = DemoModeService._internal();
  factory DemoModeService() => _instance;
  DemoModeService._internal();

  bool _isDemoMode = false;

  /// Get current demo mode state
  bool get isDemoMode => _isDemoMode;

  /// Toggle demo mode
  void toggleDemoMode() {
    _isDemoMode = !_isDemoMode;
    notifyListeners();
  }

  /// Set demo mode explicitly
  void setDemoMode(bool enabled) {
    if (_isDemoMode != enabled) {
      _isDemoMode = enabled;
      notifyListeners();
    }
  }

  /// Get demo mode status text
  String get statusText => _isDemoMode ? "Demo Mode" : "Live Mode";

  /// Get demo mode icon
  String get statusIcon => _isDemoMode ? "preview" : "database";
}
