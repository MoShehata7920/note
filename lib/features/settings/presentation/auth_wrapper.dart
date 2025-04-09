import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import 'package:note/core/utils/icons_manager.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/core/utils/utils.dart';
import 'package:note/features/settings/presentation/provider/settings_provider.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    if (!settingsProvider.useBiometricAuth) {
      setState(() => _isAuthenticated = true);
      return;
    }

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (canCheckBiometrics && isDeviceSupported) {
        final authenticated = await _localAuth.authenticate(
          localizedReason: AppStrings.authenticateToAccess.tr(),
          options: const AuthenticationOptions(biometricOnly: false),
        );
        setState(() => _isAuthenticated = authenticated);
      } else {
        setState(() => _isAuthenticated = true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Authentication error: $e');
      }
      setState(() => _isAuthenticated = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isAuthenticated ? widget.child : _buildAuthScreen();
  }

  Widget _buildAuthScreen() {
    Size size = Utils(context).screenSize;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.lock, size: 80, color: Colors.grey),
            SizedBox(height: size.height * 0.02),
            Text(
              AppStrings.pleaseAuthenticate.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.02),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text(AppStrings.tryAgain.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
