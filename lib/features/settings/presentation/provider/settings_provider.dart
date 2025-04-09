import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Locale _locale = const Locale('en');
  bool _useBiometricAuth = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;
  bool get useBiometricAuth => _useBiometricAuth;

  SettingsProvider() {
    _loadSettings();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveSettings();
    notifyListeners();
  }

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    _saveSettings();
    notifyListeners();
  }

  Future<void> toggleBiometricAuth() async {
    if (_useBiometricAuth) {
      _useBiometricAuth = false;
    } else {
      try {
        final canCheckBiometrics = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();
        if (canCheckBiometrics && isDeviceSupported) {
          final authenticated = await _localAuth.authenticate(
            localizedReason: 'Enable biometric authentication for the app',
            options: const AuthenticationOptions(
              biometricOnly: false,
            ), // Allows fallback to PIN/password
          );
          if (authenticated) {
            _useBiometricAuth = true;
          } else {
            return;
          }
        } else {
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error toggling biometric auth: $e');
        }
        return;
      }
    }
    _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _useBiometricAuth = prefs.getBool('useBiometricAuth') ?? false;
    final lang = prefs.getString('language');
    _locale = lang == 'ar' ? const Locale('ar') : const Locale('en');
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('useBiometricAuth', _useBiometricAuth);
    await prefs.setString('language', _locale.languageCode);
  }
}
