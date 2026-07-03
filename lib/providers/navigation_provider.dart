import 'package:flutter/foundation.dart';

/// Manages the selected tab index of the home navigation shell.
/// Extends [ChangeNotifier] to update the consumer widgets when modified,
/// ensuring we can manage tab state without calling `setState()`.
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }
}
