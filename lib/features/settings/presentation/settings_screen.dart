import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:note/core/utils/constants.dart';
import 'package:note/core/utils/icons_manager.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/core/widgets/app_text.dart';
import 'package:note/features/settings/presentation/provider/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: AppText(
          text: AppStrings.settings.tr(),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return ListView(
              children: [
                _buildSectionTitle(context, AppStrings.general.tr()),
                _buildCard(
                  context,
                  title: AppStrings.darkMode.tr(),
                  icon: Icons.brightness_6,
                  trailing: Switch(
                    value: settingsProvider.isDarkMode,
                    onChanged: (value) => settingsProvider.toggleTheme(),
                    activeColor: Theme.of(context).colorScheme.secondary,
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[200],
                    activeTrackColor: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                ),
                _buildCard(
                  context,
                  title: AppStrings.language.tr(),
                  icon: Icons.language,
                  trailing: DropdownButton<Locale>(
                    value: settingsProvider.locale,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(
                        value: const Locale('en'),
                        child: AppText(
                          text: AppConstants.english,
                          fontSize: 16,
                        ),
                      ),
                      DropdownMenuItem(
                        value: const Locale('ar'),
                        child: AppText(text: AppConstants.arabic, fontSize: 16),
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
                _buildSectionTitle(context, AppStrings.security.tr()),
                _buildCard(
                  context,
                  title: AppStrings.biometricAuth.tr(),
                  icon: Icons.fingerprint,
                  trailing: Switch(
                    value: settingsProvider.useBiometricAuth,
                    onChanged: (value) async {
                      await settingsProvider.toggleBiometricAuth();
                    },
                    activeColor: Theme.of(context).colorScheme.secondary,
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[200],
                    activeTrackColor: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                ),
                _buildSectionTitle(context, AppStrings.moreInfo.tr()),
                _buildCard(
                  context,
                  title: AppStrings.aboutApp.tr(),
                  icon: AppIcons.about,
                  tapFunction: () {
                    showAboutDialog(
                      context: context,
                      applicationName: AppConstants.applicationName,
                      applicationVersion: AppConstants.applicationVersion,
                      applicationLegalese: AppConstants.applicationLegalese,
                      applicationIcon: Icon(
                        AppIcons.about,
                        size: 40,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: AppText(
        text: title,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    Widget? trailing,
    Function? tapFunction,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.secondary,
          size: 28,
        ),
        title: AppText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        onTap: () => tapFunction?.call(),
      ),
    );
  }
}
