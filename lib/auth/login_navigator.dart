import 'dart:async';

import 'package:flutter/material.dart';
import 'package:truk_fleet/Routes/routes.dart';
import 'package:truk_fleet/auth/argument_class.dart';
import 'package:truk_fleet/auth/register/register_page.dart';
import 'package:truk_fleet/driver/pages/driver_homepage.dart';
import 'package:truk_fleet/helper/login_type.dart';
import 'package:truk_fleet/screens/carousel_screen.dart';
import 'package:truk_fleet/screens/fleetSelection_screen.dart';
import 'package:truk_fleet/auth/verification/otp_page.dart';
import 'package:truk_fleet/screens/splash_screen.dart';
import 'package:truk_fleet/company/pages/company_home.dart';
import 'login/login_page.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LoginRoutes {
  static const String selectionType = 'selection';
  static const String loginRoot = 'login';
  static const String splash = 'splash/';
  static const String carousel = 'carousel';
  static const String registration = 'registration';
  static const String verification = 'verification';
}

class LoginNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var canPop = navigatorKey.currentState.canPop();
        if (canPop) {
          navigatorKey.currentState.pop();
        }
        return !canPop;
      },
      child: Navigator(
        key: navigatorKey,
        initialRoute: LoginRoutes.splash,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case LoginRoutes.splash:
              builder = (BuildContext _) => Splash(
                    splashCallBack: (islogin, isOld, type) => Timer(
                      Duration(seconds: 2),
                      () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => !isOld
                                ? CarouselScreen()
                                : (islogin
                                    ? (type == LoginType.driver ? DriverHomeScreen() : CompanyHome())
                                    : FleetSelection())),
                      ),
                    ),
                  );
              break;
            case LoginRoutes.carousel:
              builder = (BuildContext _) => CarouselScreen();
              break;
            case LoginRoutes.selectionType:
              builder = (BuildContext _) => FleetSelection();
              break;
            case LoginRoutes.loginRoot:
              builder = (BuildContext _) => LoginPage(settings.arguments as String);
              break;
            case LoginRoutes.registration:
              builder = (BuildContext _) => RegisterPage(settings.arguments as String);
              //RegistrationPage(settings.arguments as String);
              break;
            case LoginRoutes.verification:
              builder = (BuildContext _) => OtpPage(
                    args: settings.arguments as OtpArguments,
                    otpCallBack: (user) {
                      Navigator.pushNamedAndRemoveUntil(context, PageRoutes.driverHome, (b) => false);
                    },
                  );
              break;
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
        onPopPage: (Route<dynamic> route, dynamic result) {
          return route.didPop(result);
        },
      ),
    );
  }
}
