import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider with ChangeNotifier {
  bool _isGridView = true;
  String _sortMode = 'date';
  static const String _viewModeKey = 'isGridView';
  static const String _sortModeKey = 'sortMode';

  HomeProvider() {
    _loadPreferences();
  }

  bool get isGridView => _isGridView;
  String get sortMode => _sortMode;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isGridView = prefs.getBool(_viewModeKey) ?? true;
      _sortMode = prefs.getString(_sortModeKey) ?? 'date';
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences: $e');
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

  Future<void> setSortMode(String sortMode) async {
    try {
      _sortMode = sortMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sortModeKey, _sortMode);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving sort mode: $e');
      }
    }
  }
}
