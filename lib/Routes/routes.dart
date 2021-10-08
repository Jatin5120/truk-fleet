import 'package:flutter/material.dart';
import 'package:truk_fleet/driver/pages/driver_homepage.dart';
import 'package:truk_fleet/company/pages/company_home.dart';

class PageRoutes {
  static const String fleetSelection = 'selection';
  static const String loginPage = 'login';
  static const String registerPage = 'registration';
  static const String verificationPage = 'verification';
  static const String carousel = 'carousel';
  static const String driverHome = 'driver_home';
  static const String companyHome = 'company_home';
  static const String splashPage = 'splash/';
  Map<String, WidgetBuilder> routes() {
    return {
      //common
      // carousel: (BuildContext _) => CarouselScreen(),
      // fleetSelection: (BuildContext _) => FleetSelection(),
      //driver
      driverHome: (context) => DriverHomeScreen(),
      //fleet
      companyHome: (context) => CompanyHome(),
    };
  }
}
