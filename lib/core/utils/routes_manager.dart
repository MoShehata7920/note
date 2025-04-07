import 'package:flutter/material.dart';
import 'package:note/core/utils/strings_manager.dart';
import 'package:note/features/home/home.dart';
import 'package:note/features/splash/splash_screen.dart';

class Routes {
  static const String splashRoute = '/';
  static const String homeRoute = '/homeRoute';
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (context) => const SplashScreen());

      case Routes.homeRoute:
        return MaterialPageRoute(builder: (context) => const HomeScreen());

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder:
          (context) => Scaffold(
            appBar: AppBar(title: Text(AppStrings.noRouteTitle)),
            body: Center(child: Text(AppStrings.noRouteFound)),
          ),
    );
  }
}
