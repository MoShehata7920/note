import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:note/core/utils/constants.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/features/settings/presentation/provider/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.settings.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return Column(
              children: [
                ListTile(
                  title: Text(AppStrings.darkMode),
                  trailing: Switch(
                    value: settingsProvider.isDarkMode,
                    onChanged: (bool value) {
                      settingsProvider.toggleTheme();
                    },
                  ),
                ),
                ListTile(
                  title: const Text(AppStrings.language),
                  trailing: DropdownButton<Locale>(
                    value: settingsProvider.locale,
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text(AppConstants.english),
                      ),
                      DropdownMenuItem(
                        value: Locale('ar'),
                        child: Text(AppConstants.arabic),
                      ),
                    ],
                    onChanged: (locale) {
                      if (locale != null) {
                        settingsProvider.setLocale(locale);
                        context.setLocale(locale);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
