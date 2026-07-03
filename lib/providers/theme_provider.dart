import 'package:flutter/material.dart';

/// Light/dark/system theme toggle backed by a [ChangeNotifier].
///
/// Cycles through `light → dark → system → light …` so the user can
/// always get out of any state. The provider does **not** persist: the
/// assignment explicitly keeps everything in memory.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;
  bool get isSystem => _mode == ThemeMode.system;

  /// Advance to the next mode and notify listeners.
  void cycle() {
    switch (_mode) {
      case ThemeMode.light:
        _mode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _mode = ThemeMode.system;
        break;
      case ThemeMode.system:
        _mode = ThemeMode.light;
        break;
    }
    notifyListeners();
  }

  /// Force a specific mode (e.g. from a future settings menu).
  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
