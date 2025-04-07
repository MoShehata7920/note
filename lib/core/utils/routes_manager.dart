import 'package:flutter/material.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/core/widgets/app_text.dart';
import 'package:note/features/add_note/presentation/add_note_screen.dart';
import 'package:note/features/home/home.dart';
import 'package:note/features/settings/presentation/settings_screen.dart';
import 'package:note/features/splash/splash_screen.dart';

class Routes {
  static const String splashRoute = '/';
  static const String homeRoute = '/homeRoute';
  static const String settingsRoute = '/settingsRoute';
  static const String addNoteRoute = '/addNoteRoute';
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (context) => const SplashScreen());

      case Routes.homeRoute:
        return MaterialPageRoute(builder: (context) => const HomeScreen());

      case Routes.settingsRoute:
        return MaterialPageRoute(builder: (context) => const SettingsScreen());

      case Routes.addNoteRoute:
        return MaterialPageRoute(builder: (context) => const AddNoteScreen());

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: AppText(text: AppStrings.noRouteTitle)),
            body: Center(child: AppText(text: AppStrings.noRouteFound)),
          ),
    );
  }
}
