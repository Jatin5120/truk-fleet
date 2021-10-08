import 'package:flutter/cupertino.dart';
import 'package:truk_fleet/Routes/routes.dart';
import 'package:truk_fleet/helper/login_type.dart';
import 'package:flutter/material.dart';
import '../sessionmanagement/session_manager.dart';

class Splash extends StatefulWidget {
  final Function(bool islogin, bool isOld, String type) splashCallBack;
  Splash({this.splashCallBack});
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    handleTimer();
  }

  handleTimer() async {
    bool isOld = await SharedPref().isOld();
    bool isLogin = await SharedPref().isLoggedIn();
    String homeRoute = PageRoutes.driverHome;
    String type = LoginType.driver;
    if (isLogin) {
      type = await SharedPref().getLoginType() ?? LoginType.driver;
      if (type == LoginType.company) homeRoute = PageRoutes.companyHome;
    }
    widget.splashCallBack(isLogin, isOld, type);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: size.height,
        width: size.width,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Image.asset(
              'assets/images/logo.png',
              height: 80,
            ),
          ),
        ),
      ),
    );
  }
}
