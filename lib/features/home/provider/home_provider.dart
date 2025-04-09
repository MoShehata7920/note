import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider with ChangeNotifier {
  bool _isGridView = true;
  static const String _viewModeKey = 'isGridView';

  HomeProvider() {
    _loadViewMode();
  }

  bool get isGridView => _isGridView;

  Future<void> _loadViewMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isGridView = prefs.getBool(_viewModeKey) ?? true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading view mode: $e');
      }
    }
  }

  Future<void> toggleViewMode() async {
    try {
      _isGridView = !_isGridView;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_viewModeKey, _isGridView);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving view mode: $e');
      }
    }
  }
}
